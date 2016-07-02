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

program Unittests;

{$IFOPT Q-}
{.$MESSAGE ERROR 'Switch on overflow check'}
{$ENDIF}

{$IFOPT R-}
{.$MESSAGE ERROR 'Switch on range check'}
{$ENDIF}

uses
{$IFDEF LINUX}
  cthreads,
{$ENDIF}
{$IFDEF DARAJA_LOGGING}
  djLogAPI, djLogOverSimpleLogger, SimpleLogger,
{$ENDIF}
  Forms,
  Interfaces,
  djRestfulComponent in '..\main\djRestfulComponent.pas',
  rsConfiguration in '..\main\rsConfiguration.pas',
  rsGlobal in '..\main\rsGlobal.pas',
  rsInterfaces in '..\main\rsInterfaces.pas',
  rsRoute in '..\main\rsRoute.pas',
  rsRouteCriteria in '..\main\rsRouteCriteria.pas',
  rsRouteMappings in '..\main\rsRouteMappings.pas',
  TestRestful in 'TestRestful.pas',
  testregistry,
  fpcunit,
  GuiTestRunner,
  consoletestrunner;

{$R *.res}

var
  Tests: TTestSuite;
  UseConsoleTestRunner: Boolean;
begin
  {$IFDEF LINUX}
  GIdIconvUseTransliteration := True;
  {$ENDIF}

  UseConsoleTestRunner := ParamCount > 0;

  {$IFDEF DARAJA_LOGGING}
  SimpleLogger.Configure('showDateTime', 'true');
  SimpleLogger.Configure('defaultLogLevel', 'trace');
  {$ENDIF DARAJA_LOGGING}

  Tests := TTestSuite.Create('restful');
  Tests.AddTest(TTestSuite.Create(TRestfulTests));

  RegisterTest('', Tests);

  if UseConsoleTestRunner then
  begin
    // Launch console Test Runner --------------------------------------------
    consoletestrunner.TTestRunner.Create(nil).Run;

    {$IFNDEF LINUX}
    ReadLn;
    {$ENDIF}
  end else begin
    // Launch GUI Test Runner ------------------------------------------------
    Application.Initialize;
    Application.CreateForm(TGuiTestRunner, TestRunner);
    TestRunner.Caption := 'Daraja Restful FPCUnit tests';
    Application.Run;
  end;

  {$IFNDEF LINUX}
  SetHeapTraceOutput('heaptrace.log');
  {$ENDIF}
end.
