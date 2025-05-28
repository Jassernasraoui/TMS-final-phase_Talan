page 77018 "TMS Process Workflow"
{
    PageType = CardPart;
    Caption = 'TMS Process Workflow';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(WorkflowSteps)
            {
                ShowCaption = false;

                group(Step1)
                {
                    Caption = '1. Planning';
                    InstructionalText = 'Create and plan tours from source documents (sales orders, purchase orders, transfers). Assign resources and optimize routes.';

                    field(PlanAction; PlanActionTxt)
                    {
                        ApplicationArea = All;
                        StyleExpr = 'Favorable';
                        DrillDown = true;
                        ToolTip = 'Go to Tour Planning to create and manage tour plans';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Tour Planning List");
                        end;
                    }
                }

                group(Arrow1)
                {
                    ShowCaption = false;
                    InstructionalText = '→';
                }

                group(Step2)
                {
                    Caption = '2. Loading';
                    InstructionalText = 'Prepare vehicle loading from planning and validate loading sheet before proceeding to charging.';

                    field(LoadAction; LoadActionTxt)
                    {
                        ApplicationArea = All;
                        StyleExpr = 'Ambiguous';
                        DrillDown = true;
                        ToolTip = 'Go to Vehicle Loading to prepare loading sheets';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Vehicle Loading List");
                        end;
                    }
                }

                group(Arrow2)
                {
                    ShowCaption = false;
                    InstructionalText = '→';
                }

                group(Step3)
                {
                    Caption = '3. Charging';
                    InstructionalText = 'Perform vehicle charging based on validated loading sheet. Update and verify actual quantities.';

                    field(ChargingAction; ChargingActionTxt)
                    {
                        ApplicationArea = All;
                        StyleExpr = 'Attention';
                        DrillDown = true;
                        ToolTip = 'Go to Vehicle Charging to manage charging operations';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Vehicle Charging List");
                        end;
                    }
                }

                group(Arrow3)
                {
                    ShowCaption = false;
                    InstructionalText = '→';
                }

                group(Step4)
                {
                    Caption = '4. Execution';
                    InstructionalText = 'Execute tours after completion of charging. Record delivery status for each stop.';

                    field(ExecutionAction; ExecutionActionTxt)
                    {
                        ApplicationArea = All;
                        StyleExpr = 'StrongAccent';
                        DrillDown = true;
                        ToolTip = 'Go to Tour Execution to manage tour delivery execution';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Tour Execution Tracking List");
                        end;
                    }
                }
            }
        }
    }

    var
        PlanActionTxt: Label 'Go to Planning';
        LoadActionTxt: Label 'Go to Loading';
        ChargingActionTxt: Label 'Go to Charging';
        ExecutionActionTxt: Label 'Go to Execution';
}