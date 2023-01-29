﻿(*

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

unit djRestfulComponent;

{$i IdCompilerDefines.inc}

interface

uses
  rsRoute, rsRouteMappings, rsConfiguration, rsRouteCriteria, rsGlobal,
  rsInterfaces, djWebComponent, djServerContext, djInterfaces,
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLoggerFactory,
{$ENDIF DARAJA_LOGGING}
  IdCustomHTTPServer;

type
  (**
   * An experimental RESTful Web Component.
   *)
  TdjRestfulComponent = class(TdjWebComponent)
  private
{$IFDEF DARAJA_LOGGING}
    Logger: ILogger;
{$ENDIF DARAJA_LOGGING}

    ContextPath: string;

    RestConfig: TrsConfiguration;

    procedure Trace(const S: string);

    procedure DELETE(const Route: IRoute); overload;
    procedure GET(const Route: IRoute); overload;
    procedure HEAD(const Route: IRoute); overload;
    procedure PATCH(const Route: IRoute); overload;
    procedure POST(const Route: IRoute); overload;
    procedure PUT(const Route: IRoute); overload;
    procedure OPTIONS(const Route: IRoute); overload;

  protected
    procedure SendError(AResponseInfo: TIdHTTPResponseInfo; Error:
      Integer; const ErrorMessage: string = '');

    procedure AddPathParams(const RequestPath: string;
      const Route: IRoute; const ARequestInfo: TIdHTTPRequestInfo);

    procedure DoCommand(const RequestPath: string;
      const MatchingRC: IRouteCriteria;
      const Route: IRoute;
      const ARequestInfo: TIdHTTPRequestInfo;
      const AResponseInfo: TIdHTTPResponseInfo);

  public
    destructor Destroy; override;

    (**
     * Initialization of RESTful configuration and logging.
     *
     * Override this method in your custom subclass to configure
     * your RESTful service.
     *
     * This method will be called from the framework.
     *)
    procedure Init(const Config: IWebComponentConfig); override;

    (**
     * Sets the path to base URL + /your_path.
     *)
    procedure &Path(const Path: string);

    (**
     * Produces defines which MIME type is delivered
     * by a method registered with GET.
     *)
    procedure &Produces(const MediaType: string);

    (**
     * Consumes defines which MIME type is consumed by this method.
     *)
    procedure &Consumes(const MediaType: string);

    (**
     * Indicates that the following method will answer to a HTTP GET request
     *)
    procedure GET(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP POST request
     *)
    procedure POST(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP DELETE request
     *)
    procedure DELETE(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP PUT request
     *)
    procedure PUT(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP HEAD request
     *)
    procedure HEAD(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP PATCH request
     *)
    procedure PATCH(Handler: TRouteProc); overload;

    (**
     * Indicates that the following method will answer to a HTTP OPTIONS request
     *
     * Use the OPTIONS method on the URL, and look at the �Allow� header that
     * is returned. This header contains a comma-separated list of methods are
     * are supported for the resource or collection.
     *)
    procedure OPTIONS(Handler: TRouteProc); overload;

    (**
     * Service a HTTP request.
     *)
    procedure Service(Context: TdjServerContext; Request: TIdHTTPRequestInfo;
      Response: TIdHTTPResponseInfo); override;
  end;

implementation

uses
  Classes, SysUtils;

{ TdjRestfulComponent }

destructor TdjRestfulComponent.Destroy;
begin
  RestConfig.Free;

  inherited;
end;

procedure TdjRestfulComponent.Init(const Config: IWebComponentConfig);
begin
  inherited; // always call inherited Init;

{$IFDEF DARAJA_LOGGING}
  Logger := TdjLoggerFactory.GetLogger('dj.' + ClassName);
{$ENDIF DARAJA_LOGGING}

  ContextPath := Config.GetContext.GetContextPath;
  Trace(ContextPath);

  RestConfig := TrsConfiguration.Create;
end;

procedure TdjRestfulComponent.Trace(const S: string);
begin
{$IFDEF DARAJA_LOGGING}
  Logger.Trace(ClassName + ': ' + S);
{$ENDIF DARAJA_LOGGING}
end;

procedure TdjRestfulComponent.SendError(AResponseInfo: TIdHTTPResponseInfo;
  Error: Integer; const ErrorMessage: string);
begin
  AResponseInfo.ResponseNo := Error;

  if ErrorMessage = '' then
  begin
    AResponseInfo.ContentText :=
      Format('<html><body><h1>%d %s</h1><p>%s</p></body></html>',
      [AResponseInfo.ResponseNo, AResponseInfo.ResponseText,
      '']);
  end
  else
  begin
    AResponseInfo.ContentText :=
      Format('<html><body><h1>%d %s</h1><p>%s</p></body></html>',
      [AResponseInfo.ResponseNo, AResponseInfo.ResponseText, ErrorMessage]);
  end;
end;

procedure TdjRestfulComponent.AddPathParams(const RequestPath: string; const
  Route: IRoute; const ARequestInfo: TIdHTTPRequestInfo);
var
  S: string;
  Temp: string;
  SL: TStrings;
begin
  if Pos('{', Route.Path) = 0 then
    Exit;

  SL := TStringList.Create;
  try
    TrsRouteCriteria.PathParams(Route.Path, RequestPath, SL);

    for S in SL do
    begin
      Temp := StringReplace(S, '{', '', []);
      Temp := StringReplace(Temp, '}', '', []);
      ARequestInfo.Params.Add(Temp);
    end;

  finally
    SL.Free;
  end;
end;

procedure TdjRestfulComponent.DoCommand(
  const RequestPath: string;
  const MatchingRC: IRouteCriteria;
  const Route: IRoute;
  const ARequestInfo: TIdHTTPRequestInfo;
  const AResponseInfo: TIdHTTPResponseInfo);
var
  RP: TRouteProc;
begin
  // check and set path parameters
  AddPathParams(RequestPath, Route, ARequestInfo);

  // set content type for GET
  if (ARequestInfo.CommandType = hcGET) and (MatchingRC.Produces <> '') then
  begin
    AResponseInfo.ContentType := MatchingRC.Produces;
  end;

  RP := Route.Handler;

  // invoke TRouteProc
  try
    RP(ARequestInfo, AResponseInfo);
  except
    on E: Exception do
    begin
{$IFDEF DARAJA_LOGGING}
      Logger.Error(ClassName + ': ' + E.Message, E);
{$ENDIF DARAJA_LOGGING}
      SendError(AResponseInfo, 500, E.ClassName + ': ' + E.Message);
    end;
  end;
end;

procedure TdjRestfulComponent.Service(Context: TdjServerContext;
  Request: TIdHTTPRequestInfo; Response: TIdHTTPResponseInfo);
var
  RouteMappings: TrsRouteMappings;
  RequestRC: IRouteCriteria;
  MatchResult: TMatchResult;
  RequestPath: string;
begin
  if ContextPath <> '' then
  begin
    RequestPath := Copy(Request.Document, Length(ContextPath) + 3, MAXINT);
  end
  else
  begin
    RequestPath := Copy(Request.Document, 2, MAXINT);
  end;

  RequestPath := Copy(RequestPath, Pos('/', RequestPath) + 1, MAXINT);

  // find a route which consumes the incoming content type
  // and produces the requested content tpye
  RequestRC := TrsRouteCriteria.Create(RequestPath, Request.ContentType, Request.Accept);

  // find the route
  RouteMappings := RestConfig.MethodMappings(Request.Command);
  MatchResult := RouteMappings.FindMatch(RequestRC);

  // either way (if Route is nil, return error message)
  if Assigned(MatchResult.Route) then
  begin
    DoCommand(RequestPath, MatchResult.RouteCriteria, MatchResult.Route, Request, Response);
  end
  else
  begin
    if RestConfig.HasMatch(RequestRC) then
    begin
      // there is a different handler registered, but not for this method:
      // Send a '405 Method not allowed'
      SendError(Response, 405,
        Format('This resource does not support "%s" requests',
        [Request.Command]));
    end
    else
    begin
      // Send a '404 Document not found'
      SendError(Response, 404);
    end;
  end;
end;

procedure TdjRestfulComponent.&Produces(const MediaType: string);
begin
  RestConfig.NextProduces := MediaType;
end;

procedure TdjRestfulComponent.&Consumes(const MediaType: string);
begin
  RestConfig.NextConsumes := MediaType;
end;

procedure TdjRestfulComponent.&Path(const Path: string);
begin
  RestConfig.SetPath(Path);
end;

procedure TdjRestfulComponent.GET(const Route: IRoute);
begin
  RestConfig.AddMapping('GET', Route);
end;

procedure TdjRestfulComponent.GET(Handler: TRouteProc);
begin
  GET(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.POST(const Route: IRoute);
begin
  RestConfig.AddMapping('POST', Route);
end;

procedure TdjRestfulComponent.POST(Handler: TRouteProc);
begin
  POST(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.DELETE(const Route: IRoute);
begin
  RestConfig.AddMapping('DELETE', Route);
end;

procedure TdjRestfulComponent.DELETE(Handler: TRouteProc);
begin
  DELETE(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.PUT(const Route: IRoute);
begin
  RestConfig.AddMapping('PUT', Route);
end;

procedure TdjRestfulComponent.PUT(Handler: TRouteProc);
begin
  PUT(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.HEAD(const Route: IRoute);
begin
  RestConfig.AddMapping('HEAD', Route);
end;

procedure TdjRestfulComponent.HEAD(Handler: TRouteProc);
begin
  HEAD(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.PATCH(const Route: IRoute);
begin
  RestConfig.AddMapping('PATCH', Route);
end;

procedure TdjRestfulComponent.PATCH(Handler: TRouteProc);
begin
  PATCH(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

procedure TdjRestfulComponent.OPTIONS(const Route: IRoute);
begin
  RestConfig.AddMapping('OPTIONS', Route);
end;

procedure TdjRestfulComponent.OPTIONS(Handler: TRouteProc);
begin
  OPTIONS(TrsRoute.Create(RestConfig.CurrentPath, Handler));
  RestConfig.ClearNextPath;
end;

end.

