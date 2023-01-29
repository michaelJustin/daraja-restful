(*

    Daraja Web Framework
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

program RESTfulDemo;

{$APPTYPE CONSOLE}

uses
  djServer,
  djWebAppContext,
  djInterfaces,
  djRestfulComponent,
  rsRoute,
  rsRouteMappings,
  rsRouteCriteria,
  rsConfiguration,
  rsGlobal,
  {$IFDEF DARAJA_LOGGING}
  djLogAPI, djLogOverSimpleLogger,
  {$ENDIF}
  ShutdownHelper in '..\common\ShutdownHelper.pas',
  ShellAPI,
  SysUtils,
  Classes;

type
  (**
   * The demo RESTful web component class.
   *)
  TMyRestfulComponent = class(TdjRestfulComponent)
  public
    procedure Init(const Config: IWebComponentConfig); override;
  end;

// deploy the web components in server and run
procedure DeployAndRunDemo;
var
  Server: TdjServer;
  Context: TdjWebAppContext;
begin
  Server := TdjServer.Create;
  try
    // add a context handler for http://127.0.0.1/
    // with HTTP session support (for Form demo)
    Context := TdjWebAppContext.Create('', True);

    // add the RESTful component at http://127.0.0.1/rest/*
    Context.Add(TMyRestfulComponent, '/rest/*');

    // add the context
    Server.Add(Context);

    // allow Ctrl+C
    SetShutdownHook(Server);

    // start
    Server.Start;

    // launch default web browser and navigate to 'form' resource
    ShellExecute(0, 'open', 'http://127.0.0.1/rest/form.html', '', '', 0);
    WriteLn('Hit any key to terminate.');
    ReadLn;

  finally
    // cleanup
    Server.Free;
  end;
end;

{ TMyRestfulComponent }

procedure TMyRestfulComponent.Init(const Config: IWebComponentConfig);
begin
  inherited; // always call inherited.Init

   // configure the RESTful services

  // /hello ------------------------------------------------------------------
  // respond to HTTP GET requests for text/html content type
  &Path('hello');
  &Produces('text/html');
  GET
    (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.ContentText :=
        '<html><title>Hello world</title>Hello world!</html>';
      Response.CharSet := 'utf-8';
    end);

  // respond to HTTP GET requests for text/xml content type
  // note that this handler uses the same resource path but different content type
  &Path('hello');
  &Produces('text/xml');
  GET
    (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.ContentText :=
        '<?xml version="1.0" ?><hello>Hello world!</hello>';
      Response.CharSet := 'utf-8';
    end);

  // /form -------------------------------------------------------------------
  &Path('form.html');
  &Produces('text/html');
  GET
   (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.ContentText := '<html><form method="POST">'
        + '<input name="var" value="hello world"><input type="submit"></form></html>';
      Response.CharSet := 'utf-8';
    end);

  &Path('form.html');
  POST
   (procedure(Request: TRequest; Response: TResponse)
    begin
      // store data
      Request.Session.Content.Values['Data'] :=
        'var=' + UTF8ToString(RawByteString(Request.Params.Values['var']));
      // then redirect to thankyou page
      Response.Redirect('thankyou.html');
    end);

  &Path('thankyou.html');
  &Produces('text/html');
  GET
   (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.ContentText := Format('<html>You entered: %s</html>',
        [Request.Session.Content.Values['Data']]);
      Response.CharSet := 'utf-8';
    end);

  // params ------------------------------------------------------------------
  &Path('params/{p1}/{p2}');
  &Produces('text/html');
  GET
    (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.ContentText :=
        Format('<html><title>Hello world</title>Hello world! ... p1="%s" p2="%s"</html>',
        [Request.Params.Values['p1'], Request.Params.Values['p2']]);
      Response.CharSet := 'utf-8';
    end);

end;

begin
  ReportMemoryLeaksOnShutdown := True;

  DeployAndRunDemo;
end.

