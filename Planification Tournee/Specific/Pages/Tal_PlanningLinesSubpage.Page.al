page 73640 "Planning Lines Subpage"
{
    PageType = ListPart;
    SourceTable = "Planning Lines";
    Caption = 'Lignes de Planning';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(PlanningLines)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro de ligne';
                    Editable = false;
                }

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le type de la ligne de planning';
                }

                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''identifiant source';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la description de la ligne';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro d''article';
                }

                field("Expected Shipment Date"; Rec."Expected Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la date d''expédition prévue';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro client';
                    Visible = Rec."Type" = Rec."Type"::Sales;
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro fournisseur';
                    Visible = Rec."Type" = Rec."Type"::Purchase;
                }

                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la priorité de la ligne';
                    StyleExpr = PriorityStyleExpr;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = '🔄 Actualiser';
                Image = Refresh;
                ToolTip = 'Actualiser la liste des lignes de planning';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        PriorityStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        // Définir le style en fonction de la priorité
        case Rec.Priority of
            Rec.Priority::Critical:
                PriorityStyleExpr := 'Unfavorable';
            Rec.Priority::High:
                PriorityStyleExpr := 'Attention';
            Rec.Priority::Low:
                PriorityStyleExpr := 'Favorable';
            else
                PriorityStyleExpr := 'Standard';
        end;
    end;
}