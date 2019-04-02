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

program RESTfulDemoCRUD;

{$APPTYPE CONSOLE}

uses
  djServer,
  djWebAppContext,
  djInterfaces,
  CRUDModuleUnit in 'CRUDModuleUnit.pas' {CRUDModule: TDataModule},
  WebComponentCRUD in 'WebComponentCRUD.pas',
  djRestfulComponent,
  rsRoute,
  rsRouteMappings,
  rsRouteCriteria,
  rsConfiguration,
  {$IFDEF DARAJA_LOGGING}
  djLogAPI, djLogOverSimpleLogger,
  {$ENDIF}
  ShutdownHelper in '..\common\ShutdownHelper.pas',
  ShellAPI,
  SysUtils,
  Classes;

// deploy the web components in server and run
procedure DeployAndRunDemo;
var
  Server: TdjServer;
  Context: TdjWebAppContext;
begin
  Server := TdjServer.Create;
  try
    // add a context handler for http://127.0.0.1/
    // (without session support)
    Context := TdjWebAppContext.Create('');

    // add the RESTful component at http://127.0.0.1/rest/*
    Context.Add(TMyRestfulComponent, '/rest/*');

    // add the context
    Server.Add(Context);

    // allow Ctrl+C
    SetShutdownHook(Server);

    // start
    Server.Start;

    // launch default web browser and navigate to 'form' resource
    ShellExecute(0, 'open', 'http://localhost/rest/persons', '', '', 0);
    WriteLn('Hit any key to terminate.');
    ReadLn;

  finally
    // cleanup
    Server.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;

  CRUDModule := TCRUDModule.Create(nil);
  try
    DeployAndRunDemo;
  finally
    CRUDModule.Free;
  end;
end.

