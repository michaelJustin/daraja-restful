(*

    Daraja Framework
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

unit rsRoute;

{$i IdCompilerDefines.inc}

interface

uses
  rsInterfaces, rsGlobal,
  {$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
  {$ENDIF DARAJA_LOGGING}
  SysUtils;

type
  (**
   * Route.
   *)
  TrsRoute = class(TInterfacedObject, IRoute)
  private
    FPath: string;
    FHandler: TRouteProc;
    function GetPath: string;
    function GetHandler: TRouteProc;
  public
    constructor Create(const Path: string; Handler: TRouteProc);
    destructor Destroy; override;

    property Path: string read GetPath;
    property Handler: TRouteProc read GetHandler;
  end;

implementation

{ TrsRoute }

constructor TrsRoute.Create(const Path: string; Handler: TRouteProc);
begin
  FPath := Path;
  FHandler := Handler;
end;

destructor TrsRoute.Destroy;
begin

  inherited;
end;

function TrsRoute.GetHandler: TRouteProc;
begin
  Result := FHandler;
end;

function TrsRoute.GetPath: string;
begin
  Result := FPath;
end;

end.
