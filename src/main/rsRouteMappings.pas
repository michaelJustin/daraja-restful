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

unit rsRouteMappings;

{$i IdCompilerDefines.inc}

interface

uses
  rsInterfaces, rsRoute, rsRouteCriteria,
  {$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
  {$ENDIF DARAJA_LOGGING}
  {$IFDEF FPC}fgl{$ELSE}Generics.Collections{$ENDIF},
  SysUtils, Classes;

type
  (**
   * Route mappings.
   *)
  TrsRouteMappings = class(TInterfacedObject, IRouteMappings)
  private
    FMappings: TObjectDictionary<TrsRouteCriteria, TrsRoute>;
  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Add(Criteria: TrsRouteCriteria; Route: TrsRoute);

    function ContainsKey(Criteria: TrsRouteCriteria): Boolean;

    function FindMatch(const ACriteria: IRouteCriteria; var Route: TrsRoute): TrsRouteCriteria;
  end;

  TrsMethodMappings = class(TInterfacedObject, IMethodMappings)
  private
    FMappings: TObjectDictionary<string, TrsRouteMappings>;
  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Add(Key: string; Value: TrsRouteMappings);

    function ContainsKey(Key: string): Boolean;

    function Methods: TStrings;

    function Mapping(Index: string): TrsRouteMappings;

  end;

implementation

{ TrsRouteMappings }

procedure TrsRouteMappings.Add(Criteria: TrsRouteCriteria; Route: TrsRoute);
begin
  FMappings.Add(Criteria, Route);
end;

function TrsRouteMappings.ContainsKey(Criteria: TrsRouteCriteria): Boolean;
begin
  Result := FMappings.ContainsKey(Criteria);
end;

constructor TrsRouteMappings.Create;
begin
  inherited ;

  FMappings := TObjectDictionary<TrsRouteCriteria, TrsRoute>.Create([doOwnsKeys, doOwnsValues], TrsCriteriaComparer.Create);
end;

destructor TrsRouteMappings.Destroy;
begin
  FMappings.Free;
end;

function TrsRouteMappings.FindMatch(const ACriteria: IRouteCriteria;
  var Route: TrsRoute): TrsRouteCriteria;
var
  MatchingRC: TrsRouteCriteria;
begin
  Route := nil;
  Result := nil;
  for MatchingRC in FMappings.Keys do
  begin
    // Log(Format('Comparing %s %s', [C.Path + C.Produces, MatchingRC.Path + MatchingRC.Produces]));
    if TrsRouteCriteria.Matches(MatchingRC, ACriteria) then
    begin
      Route := FMappings[MatchingRC];
      Result := MatchingRC;
      Break;
    end;
  end;
end;

{ TrsMethodMappings }

procedure TrsMethodMappings.Add(Key: string; Value: TrsRouteMappings);
begin
  FMappings.Add(Key, Value);
end;

function TrsMethodMappings.ContainsKey(Key: string): Boolean;
begin
  Result := FMappings.ContainsKey(Key);
end;

constructor TrsMethodMappings.Create;
begin
  inherited Create();

  FMappings := TObjectDictionary<string, TrsRouteMappings>.Create([doOwnsValues]);
end;

destructor TrsMethodMappings.Destroy;
begin
  FMappings.Free;

  inherited;
end;

function TrsMethodMappings.Mapping(Index: string): TrsRouteMappings;
begin
  Result := FMappings.Items[Index];
end;

function TrsMethodMappings.Methods: TStrings;
var
  S: string;
begin
  Result := TStringList.Create;
  for S in FMappings.Keys do Result.Add(S);
end;

end.
