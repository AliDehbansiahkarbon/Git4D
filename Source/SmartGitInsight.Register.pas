unit SmartGitInsight.Register;

interface

procedure Register;

implementation

uses
  ToolsAPI,
  SmartGitInsight.Options,
  SmartGitInsight.Wizard;

procedure Register;
begin
  RegisterSmartGitInsightOptions;
  RegisterPackageWizard(TSmartGitInsightWizard.Create);
end;

end.
