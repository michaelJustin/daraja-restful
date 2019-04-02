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

// this is unsupported demonstration code

unit WebComponentCRUD;

interface

uses
  djRestfulComponent, djInterfaces;

type
  (**
   * The demo RESTful web component class.
   * see http://persistentdesigns.com/wp/rest-crud-jersey-spring-and-jpa/
   *)
  TMyRestfulComponent = class(TdjRestfulComponent)
  public
    procedure Init(const Config: IWebComponentConfig); override;
  end;

implementation

uses
  rsRoute, rsGlobal, djTypes, CRUDModuleUnit, SysUtils;

{ TMyRestfulComponent }

procedure TMyRestfulComponent.Init(const Config: IWebComponentConfig);
begin
  inherited; // always call inherited.Init

  // set the base path for the 'persons' resource
  &Path('/persons');

  // GET http://localhost/rest/persons
  // list all persons
  Produces('text/html');
  GET(procedure(Request: TdjRequest; Response: TdjResponse)
  begin
    Response.ContentText := CRUDModule.GetPersons;
    Response.CharSet := 'UTF-8';
  end);

  // POST http://localhost/rest/persons
  // add new person
  Produces('text/html');
  POST(procedure(Request: TdjRequest; Response: TdjResponse)
  var
    Name: string;
    Person: TPerson;
  begin
    Name := UTF8Decode(Request.Params.Values['name']);
    Person := TPerson.Create(CRUDModule.NextID, Name);
    CRUDModule.SavePerson(Person);
    Response.Redirect(Request.Document);
  end);

  // PUT http://localhost/rest/persons
  // update person
  &Path('{id}');
  Produces('text/html');
  PUT(procedure(Request: TdjRequest; Response: TdjResponse)
  var
    ID: string;
  begin
    ID := Request.Params.Values['id'];
    // TODO
  end);

  // DELETE http://localhost/rest/persons/{id}
  // delete person
  &Path('{id}');
  Produces('text/html');
  DELETE(procedure(Request: TdjRequest; Response: TdjResponse)
  var
    ID: string;
  begin
    ID := Request.Params.Values['id'];
    CRUDModule.DeletePerson(StrToInt(ID));
  end);

  // GET http://localhost/rest/persons/
  // get person information
  &Path('{id}');
  Produces('text/html');
  GET(procedure(Request: TdjRequest; Response: TdjResponse)
  var
    ID: string;
  begin
    ID := Request.Params.Values['id'];
    Response.ContentText := CRUDModule.GetPerson(StrToInt(ID));
    Response.CharSet := 'UTF-8';
  end);
end;

end.
