(*
    Daraja Framework
    Copyright (C) 2016 Michael Justin

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

unit TestRestful;

interface

uses
  TestFramework;

type
  TRestfulTests = class(TTestCase)
  private

  published
    procedure TestGET;

    procedure TestPATCH;

    procedure TestOPTIONS;

    procedure TestTrsRoute;

    procedure TestTrsRouteCriteria;
  end;

implementation

uses
  rsConfiguration, rsRoute, rsRouteCriteria, rsRouteMappings,
  rsGlobal, rsInterfaces,
  djRestfulComponent, djInterfaces, djServer, djWebAppContext,
  IdHTTP, Classes;

type
  TGetRestful = class(TdjRestfulComponent)
  public
    procedure Init(const Config: IWebComponentConfig); override;
  end;

  TPatchRestful = class(TdjRestfulComponent)
  public
    procedure Init(const Config: IWebComponentConfig); override;
  end;

  TOptionsRestful = class(TdjRestfulComponent)
  public
    procedure Init(const Config: IWebComponentConfig); override;
  end;

{ TGetRestful }

procedure TGetRestful.Init(const Config: IWebComponentConfig);
begin
  inherited;

  &Path('/files');
  &Path('{param}');
  GET
    (procedure(Request: TRequest; Response: TResponse)
    begin

    end);
end;

{ TPatchRestful }

procedure TPatchRestful.Init(const Config: IWebComponentConfig);
begin
  inherited;

  &Path('/files');
  &Path('{param}');
  PATCH
    (procedure(Request: TRequest; Response: TResponse)
    begin
       // see http://tools.ietf.org/html/rfc5789#section-2.1
       // no response body
       Response.ResponseNo := 204;
       Response.Location := Request.Document;
       Response.ETag := 'e0023aa4f';
    end);
end;

{ TOptionsRestful }

procedure TOptionsRestful.Init(const Config: IWebComponentConfig);
begin
  inherited;

  &Path('/');
  &Path('testoptions');
  OPTIONS
    (procedure(Request: TRequest; Response: TResponse)
    begin
      Response.CustomHeaders.AddValue('Allow', 'OPTIONS');
    end);
end;

{ TRestfulTests }

procedure TRestfulTests.TestGET;
var
  Server: TdjServer;
  Context: TdjWebAppContext;
  HTTP: TIdHTTP;
  PatchStream: TStream;
begin
  Server := TdjServer.Create;
  try
    // add a context handler for http://127.0.0.1/
    Context := TdjWebAppContext.Create('');
    // add the RESTful component at http://127.0.0.1/rest/*
    Context.Add(TGetRestful, '/rest/*');

    Server.Add(Context);
    Server.Start;

    PatchStream := TStringStream.Create('<patch>example GET content</patch>');
    try
      HTTP := TIdHTTP.Create;
      try
        HTTP.Get('http://127.0.0.1/rest/files/get.txt', PatchStream);
        CheckEquals(200, HTTP.ResponseCode);
      finally
        HTTP.Free;
      end;
    finally
      PatchStream.Free;
    end;
  finally
    Server.Free;
  end;
end;

procedure TRestfulTests.TestPATCH;
var
  Server: TdjServer;
  Context: TdjWebAppContext;
  HTTP: TIdHTTP;
  PatchStream: TStream;
begin
  Server := TdjServer.Create;
  try
    // add a context handler for http://127.0.0.1/
    Context := TdjWebAppContext.Create('');
    // add the RESTful component at http://127.0.0.1/rest/*
    Context.Add(TPatchRestful, '/rest/*');

    Server.Add(Context);
    Server.Start;

    PatchStream := TStringStream.Create('<patch>example patch content</patch>');
    try
      HTTP := TIdHTTP.Create;
      try
        HTTP.Patch('http://127.0.0.1/rest/files/file.txt', PatchStream);
        // see http://tools.ietf.org/html/rfc5789#section-2.1
        CheckEquals(204, HTTP.ResponseCode);
        CheckEquals('/rest/files/file.txt', HTTP.Response.Location);
        CheckEquals('e0023aa4f', HTTP.Response.ETag);
      finally
        HTTP.Free;
      end;
    finally
      PatchStream.Free;
    end;
  finally
    Server.Free;
  end;
end;

procedure TRestfulTests.TestOPTIONS;
var
  Server: TdjServer;
  Context: TdjWebAppContext;
  HTTP: TIdHTTP;
begin
  Server := TdjServer.Create;
  try
    // add a context handler for http://127.0.0.1/
    Context := TdjWebAppContext.Create('');
    // add the RESTful component at http://127.0.0.1/rest/*
    Context.Add(TOptionsRestful, '/rest/*');

    Server.Add(Context);
    Server.Start;

    HTTP := TIdHTTP.Create;
    try
      HTTP.Options('http://127.0.0.1/rest/testoptions');
      CheckEquals('OPTIONS', HTTP.Response.RawHeaders.Values['Allow']);
    finally
      HTTP.Free;
    end;

  finally
    Server.Free;
  end;
end;

procedure TRestfulTests.TestTrsRoute;
var
  Route: IRoute;
begin
  Route := TrsRoute.Create('path', procedure(Req: TRequest; Res: TResponse) begin end);

  CheckEquals('path', Route.Path);
end;

procedure TRestfulTests.TestTrsRouteCriteria;
var
  RC, RC2: IRouteCriteria;
begin
  RC := TrsRouteCriteria.Create('path', 'consumes', 'produces');

  CheckEquals('path', RC.NormalizedPath);
  CheckEquals('path', RC.Path);
  CheckEquals('consumes', RC.Consumes);
  CheckEquals('produces', RC.Produces);


  RC2 := TrsRouteCriteria.Create('{param1}/{param2}', 'consumes', 'produces');

  CheckEquals('{p}/{p}/', RC2.NormalizedPath);
  CheckEquals('{param1}/{param2}', RC2.Path);
  CheckEquals('consumes', RC2.Consumes);
  CheckEquals('produces', RC2.Produces);

  CheckFalse(TrsRouteCriteria.Matches(RC, RC2));
end;

end.
