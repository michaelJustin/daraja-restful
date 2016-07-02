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

unit rsInterfaces;

interface

uses
  rsGlobal,
  Classes;

type


  IContextConfiguration = interface
    ['{8D12A5C0-4C91-4A9E-BB14-3030CAFC8286}']
  end;

  IRoute = interface
    ['{7543E346-D614-45B9-97A0-84855F1889D0}']

    function GetPath: string;
    function GetHandler: TRouteProc;

    property Path: string read GetPath;
    property Handler: TRouteProc read GetHandler;
  end;

  IRouteCriteria = interface
    ['{4BC918E8-D0D5-4997-B1A0-DD1104E4046F}']

    function NormalizedPath: string;

    function GetConsumes: string;
    function GetPath: string;
    function GetProduces: string;

    property Path: string read GetPath;
    property Produces: string read GetProduces;
    property Consumes: string read GetConsumes;
  end;

  IRouteMappings = interface
    ['{0579F025-A69E-4104-BED9-0D5ED1F43523}']

    function ContainsKey(const ACriteria: IRouteCriteria): Boolean;
  end;

  IMethodMappings = interface
    ['{1F68D9B7-7A58-4F72-9DD7-D1B2767A16C1}']

    function ContainsKey(Key: string): Boolean;

    function Methods: TStrings;

  end;



implementation

end.
