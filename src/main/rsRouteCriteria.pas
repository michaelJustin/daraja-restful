(*

    Daraja HTTP Framework
    Copyright (C) Michael Justin

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

unit rsRouteCriteria;

{$i IdCompilerDefines.inc}

interface

uses
  rsInterfaces,
  Classes;

type
  (**
   * Route criteria.
   *)
  TrsRouteCriteria = class(TInterfacedObject, IRouteCriteria)
  private
    FPath: string;
    FProduces: string;
    FConsumes: string;
    function GetConsumes: string;
    function GetPath: string;
    function GetProduces: string;

    class function PathMatches(const Left, Right: string): Boolean;

  public
    constructor Create(const APath: string); overload;
    constructor Create(const APath, AConsumes: string); overload;
    constructor Create(const APath, AConsumes, AProduces: string); overload;

    function Equals(Obj: TObject): Boolean; override;

    function NormalizedPath: string;

    property Path: string read GetPath;
    property Produces: string read GetProduces;
    property Consumes: string read GetConsumes;

    class function PathParams(const Left, Right: string;
      const Params: TStrings): Boolean;
    class function Matches(const Left, Right: IRouteCriteria): Boolean;

  end;

implementation

{ TRouteCriteria }

constructor TrsRouteCriteria.Create(const APath: string);
begin
  FPath := APath;
end;

constructor TrsRouteCriteria.Create(const APath, AConsumes: string);
begin
  Create(APath);
  FConsumes := AConsumes;
end;

constructor TrsRouteCriteria.Create(const APath, AConsumes, AProduces: string);
begin
  Create(APath, AConsumes);
  FProduces := AProduces;
end;

function TrsRouteCriteria.Equals(Obj: TObject): Boolean;
var
  Tmp: TrsRouteCriteria;
begin
  if not Assigned(Obj) then
    Exit(False);
  if Obj = Self then
    Exit(True);
  if not (Obj is TrsRouteCriteria) then
    Exit(False);

  Tmp := Obj as TrsRouteCriteria;

  Result := (Self.NormalizedPath = Tmp.NormalizedPath)
    and (Self.Consumes = Tmp.Consumes)
    and (Self.Produces = Tmp.Produces)
end;

function TrsRouteCriteria.GetConsumes: string;
begin
  Result := FConsumes;
end;

function TrsRouteCriteria.GetPath: string;
begin
  Result := FPath;
end;

function TrsRouteCriteria.GetProduces: string;
begin
  Result := FProduces;
end;

class function TrsRouteCriteria.Matches(const Left, Right: IRouteCriteria): Boolean;
begin
  Result := PathMatches(Left.Path, Right.Path)
    and ((Left.Consumes = '') or (Left.Consumes = Right.Consumes))
    and ((Left.Produces = '') or (Pos(Left.Produces, Right.Produces) > 0))
end;

function TrsRouteCriteria.NormalizedPath: string;
var
  SL: TStrings;
  S: string;
  I: Integer;
begin
  if Pos('{', Path) = 0 then
    Exit(Path);

  Result := '';

  // replace all {param} occurences with {p}
  SL := TStringList.Create;
  try
    SL.StrictDelimiter := True;
    SL.Delimiter := '/';
    SL.DelimitedText := Path;
    for I := 0 to SL.Count - 1 do
    begin
      S := SL[I];
      if Pos('{', S) = 1 then
      begin
        Result := Result + '{p}/';
      end
      else
      begin
        Result := Result + S + '/';
      end;
    end;
  finally
    SL.Free;
  end;
end;

function SlashCount(const S: string): Integer;
var
  Ch: Char;
begin
  Result := 0;
  for Ch in S do
  begin
    if Ch = '/' then
      Inc(Result);
  end;
end;

class function TrsRouteCriteria.PathMatches(const Left,
  Right: string): Boolean;
begin
  if (Left = Right) then
    Exit(True);

  if Pos('{', Left) = 0 then
    Exit(False);

  if SlashCount(Left) <> SlashCount(Right) then
    Exit(False);

  if not PathParams(Left, Right, nil) then
    Exit(False);

  Exit(True);
end;

class function TrsRouteCriteria.PathParams(const Left,
  Right: string; const Params: TStrings): Boolean;
var
  SLL, SLR: TStrings;
  I: Integer;
  SL: string;
begin
  SLL := TStringlist.Create;
  try
    SLL.StrictDelimiter := True;
    SLL.Delimiter := '/';
    SLL.DelimitedText := Left;

    SLR := TStringlist.Create;
    try
      SLR.StrictDelimiter := True;
      SLR.Delimiter := '/';
      SLR.DelimitedText := Right;

      Assert(SLL.Count = SLR.Count);

      // compare URI path pattern with actual request
      // e.g.
      // compare "path/with/{param}" with "path/with/12345"

      for I := 0 to SLL.Count - 1 do
      begin
        SL := SLL[I];

        if Pos('{', SL) = 1 then
        begin
          if Assigned(Params) then
          begin
            // called to extract the param values:
            Params.Values[SLL[I]] := SLR[I];
          end;

        end
        else
        begin
          if SL <> SLR[I] then
          begin
            Exit(False);
          end;
        end;
      end;

    finally
      SLR.Free;
    end;

  finally
    SLL.Free;
  end;

  Result := True;
end;

end.

