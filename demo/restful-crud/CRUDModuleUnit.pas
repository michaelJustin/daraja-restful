(*

    Daraja Framework
    Copyright (C) 2016  Michael Justin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving the Daraja framework without
    disclosing the source code of your own applications. These activities
    include: offering paid services to customers as an ASP, shipping Daraja 
    with a closed source product.

*)

// this is unsupported demonstration code

unit CRUDModuleUnit;

interface

uses
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
{$ENDIF DARAJA_LOGGING}
  IdThreadsafe,
  SysUtils, Classes, Generics.Collections;

type
  TPerson = class(TObject)
  private
    FName: string;
    FID: Integer;
  public
    constructor Create(AID: Integer; AName: string);

    property ID: Integer read FID;
    property Name: string read FName;
  end;

  TBuilder = class(TObject)
  public
    class function Head: string;
    class function BodyEnd: string;
  end;

  TPersons = class(TDictionary<Integer, TPerson>)
  end;

  TCRUDModule = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}
    Persons: TPersons;

    SeqGen: TIdThreadSafeInteger;
  public
    function NextID: Integer;
    // get all persons as HTML
    function GetPersons: string;
    // create new person record
    procedure SavePerson(const APerson: TPerson);
    // delete person record
    procedure DeletePerson(const ID: Integer);
    // get person record as HTML
    function GetPerson(const ID: Integer): string;
  end;

var
  CRUDModule: TCRUDModule;

implementation

{$R *.dfm}

function Pretty(const AText: string): string;
begin
  Result := StringReplace(AText, '>', '>'+#10, [rfReplaceAll]);
  Result := StringReplace(Result, '</', #10 + '</', [rfReplaceAll]);
end;

{ TPerson }

constructor TPerson.Create(AID: Integer; AName: string);
begin
  FID := AID;
  FName := AName;
end;

{ TBuilder }

class function TBuilder.Head: string;
begin
  Result :=
      '<!DOCTYPE html>'
    + '<html>'
    + '  <head>'
    + '    <title>Daraja Framework</title>'
    + '  </head>'
    + '    <!-- jQuery --> '
    + '    <script src="//code.jquery.com/jquery.js"></script>'
    + '  <body>';
end;

class function TBuilder.BodyEnd: string;
begin
  Result :=
    '  </body>'
  + '</html>';
end;

{ TCRUDModule }

procedure TCRUDModule.DataModuleCreate(Sender: TObject);
var
  Person: TPerson;
begin
{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('crud.' + ClassName);
{$ENDIF DARAJA_LOGGING}
  SeqGen := TIdThreadSafeInteger.Create;
  Persons := TPersons.Create;

  // populate the person list with example data
  Person := TPerson.Create(NextID, 'Leonhard');
  Persons.Add(Person.ID, Person);
  Person := TPerson.Create(NextID, 'Lily');
  Persons.Add(Person.ID, Person);
  Person := TPerson.Create(NextID, 'Anonymous');
  Persons.Add(Person.ID, Person);
end;

procedure TCRUDModule.DataModuleDestroy(Sender: TObject);
var
  P: TPerson;
begin
  for P in Persons.Values do
    P.Free;

  Persons.Free;

  SeqGen.Free;
end;

function TCRUDModule.NextID: Integer;
begin
  Result := SeqGen.Increment;
end;

procedure TCRUDModule.DeletePerson(const ID: Integer);
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Info('delete person');
{$ENDIF DARAJA_LOGGING}
  Persons.Items[ID].Free;
  Persons.Remove(ID);
end;

function TCRUDModule.GetPerson(const ID: Integer): string;
var
  P: TPerson;
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Info('get person');
{$ENDIF DARAJA_LOGGING}

  if not Persons.ContainsKey(ID) then
  begin
    Result := TBuilder.Head + 'not found' + TBuilder.BodyEnd;
  end
  else
  begin
    P := Persons.Items[ID];

    Result := TBuilder.Head
     + '<p>' + P.Name + '</p>'
     + '<button>Delete</button>'
     + '<script type="text/javascript">'
     + '$(document).ready(function(){' + #10
     + '$("button").click(function(){' + #10
     + ' $.ajax({url:'
     + Format('"/rest/persons/%d"', [ID])
     + ',type:"DELETE",dataType:"html"});' + #10
     + '});' + #10
     + '});' + #10
     + '</script>'
     + TBuilder.BodyEnd;
  end;

  Result := Pretty(Result);
end;

function TCRUDModule.GetPersons: string;
var
  P: TPair<Integer, TPerson>;
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Info('get all persons');
{$ENDIF DARAJA_LOGGING}

  Result := TBuilder.Head;

  for P in Persons do
  begin
    Result := Result
      + '  <p>'
      + P.Value.Name
      + ' - '
      + Format('<a href="persons/%d">show</a>', [P.Key])
      + '  </p>';
  end;

  Result := Result
    + '  <form method="POST">'
    + '    <input type="submit" value="Add"/>'
    + '    <input type="text" name="name" />'
    + '  </form>'
    + TBuilder.BodyEnd;

  Result := Pretty(Result);
end;

procedure TCRUDModule.SavePerson(const APerson: TPerson);
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Info('add new person');
{$ENDIF DARAJA_LOGGING}
  Persons.Add(APerson.ID, APerson);
end;

end.
