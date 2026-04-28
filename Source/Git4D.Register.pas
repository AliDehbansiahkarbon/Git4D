unit Git4D.Register;

interface

procedure Register;

implementation

uses
  ToolsAPI,
  Git4D.Options,
  Git4D.Wizard;

procedure Register;
begin
  RegisterGit4DOptions;
  RegisterPackageWizard(TGit4DWizard.Create);
end;

initialization

finalization
  UnregisterGit4DOptions;

end.

