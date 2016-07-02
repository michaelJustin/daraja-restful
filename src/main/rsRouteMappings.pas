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
  rsInterfaces, rsRoute, rsRouteCriteria, rsGlobal,
  {$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
  {$ENDIF DARAJA_LOGGING}
  Contnrs,
  SysUtils, Classes;

type
  TMatchResult = record
    RouteCriteria: IRouteCriteria;
    Route: TrsRoute;
  end;

  (**
   * Route mappings.
   *)
  TrsRouteMappings = class(TInterfacedObject, IRouteMappings)
  private
    FRouteCriteriaList: TInterfaceList;
    FRouteList: TObjectList;
  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Add(const ACriteria: IRouteCriteria; const ARoute: TrsRoute);

    function ContainsKey(const ACriteria: IRouteCriteria): Boolean;

    function FindMatch(const ACriteria: IRouteCriteria): TMatchResult;
  end;

  TrsMethodMappings = class(TInterfacedObject, IMethodMappings)
  private
    FMappings: TStrings;
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

constructor TrsRouteMappings.Create;
begin
  inherited;

  FRouteCriteriaList := TInterfaceList.Create;
  FRouteList := TObjectList.Create(True);
end;

destructor TrsRouteMappings.Destroy;
begin
  FRouteCriteriaList.Free;
  FRouteList.Free;
end;

procedure TrsRouteMappings.Add(const ACriteria: IRouteCriteria; const ARoute: TrsRoute);
begin
  FRouteCriteriaList.Add(ACriteria);
  FRouteList.Add(ARoute);
end;

function TrsRouteMappings.ContainsKey(const ACriteria: IRouteCriteria): Boolean;
begin
  Result := FRouteCriteriaList.IndexOf(ACriteria) > -1;
end;

function TrsRouteMappings.FindMatch(const ACriteria: IRouteCriteria): TMatchResult;
var
  MatchingRC: IRouteCriteria;
  I: Integer;
begin
  Result := Default(TMatchResult);
  Result.RouteCriteria := nil;
  Result.Route := nil;
  for I := 0 to FRouteCriteriaList.Count - 1 do
  begin
    MatchingRC := FRouteCriteriaList[I] as IRouteCriteria;
    // Log(Format('Comparing %s %s', [C.Path + C.Produces, MatchingRC.Path + MatchingRC.Produces]));
    if TrsRouteCriteria.Matches(MatchingRC, ACriteria) then
    begin
      Result.Route := FRouteList[I] as TrsRoute;
      Result.RouteCriteria := MatchingRC;
      Break;
    end;
  end;
end;

{ TrsMethodMappings }

procedure TrsMethodMappings.Add(Key: string; Value: TrsRouteMappings);
begin
  FMappings.AddObject(Key, Value);
end;

function TrsMethodMappings.ContainsKey(Key: string): Boolean;
begin
  Result := FMappings.IndexOf(Key) > -1;
end;

constructor TrsMethodMappings.Create;
begin
  inherited;

  FMappings := TStringList.Create;
end;

destructor TrsMethodMappings.Destroy;
var
  I: Integer;
begin
  for I := 0 to FMappings.Count - 1 do FMappings.Objects[I].Free;

  FMappings.Free;

  inherited;
end;

function TrsMethodMappings.Mapping(Index: string): TrsRouteMappings;
begin
  Result := FMappings.Objects[FMappings.IndexOf(Index)] as TrsRouteMappings;
end;

function TrsMethodMappings.Methods: TStrings;
begin
  Result := FMappings;
end;

end.
