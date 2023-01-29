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
    develop commercial activities involving the software without
    disclosing the source code of your own applications. These activities
    include: offering paid services to customers as an ASP, serving resources
    in a web application, shipping the Daraja Web Framework with a closed
    source product.
*)

program Unittests;

{$APPTYPE CONSOLE}

uses
  djLogAPI,
  djLogOverSimpleLogger,
  djRestfulComponent in '..\main\djRestfulComponent.pas',
  rsConfiguration in '..\main\rsConfiguration.pas',
  rsRoute in '..\main\rsRoute.pas',
  rsRouteCriteria in '..\main\rsRouteCriteria.pas',
  rsRouteMappings in '..\main\rsRouteMappings.pas',
  rsInterfaces in '..\main\rsInterfaces.pas',
  rsGlobal in '..\main\rsGlobal.pas',
  TestRestful in 'TestRestful.pas',
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  SysUtils;

begin
  ReportMemoryLeaksOnShutdown := True;

  RegisterTests('', [TRestfulTests.Suite]);

  if FindCmdLineSwitch('text-mode', ['-', '/'], true) then
    TextTestRunner.RunRegisteredTests(rxbContinue)
  else
  begin
    ReportMemoryLeaksOnShutDown := True;
    TGUITestRunner.RunRegisteredTests;
  end;
end.

