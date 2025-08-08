page 73560 "Tour Details FactBox"
{
    Caption = 'Détails Tournée';
    PageType = CardPart;
    SourceTable = "Planification Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Général';
                field("Logistic Tour No."; Rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le numéro de la tournée.';
                }
                field("Date de Tournée"; Rec."Date de Tournée")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie la date de la tournée.';
                }
                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le chauffeur assigné à la tournée.';
                }
                field("Véhicule No."; Rec."Véhicule No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le véhicule assigné à la tournée.';
                }
                field("Statut"; Rec.Statut)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyleExpr;
                    ToolTip = 'Affiche le statut actuel de la tournée.';
                }
                field("No. of Planning Lines"; Rec."No. of Planning Lines")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique le nombre de lignes de planification pour cette tournée.';
                }
                field("Estimated Total Weight"; Rec."Estimated Total Weight")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Affiche le poids total estimé pour cette tournée.';
                }
                field("Estimated Distance"; Rec."Estimated Distance")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique la distance totale estimée pour cette tournée.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Indique qui a créé cette tournée.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    var
        StatusStyleExpr: Text;

    local procedure UpdateStatusStyle()
    begin
        case Rec.Statut of
            Rec.Statut::Plannified:
                StatusStyleExpr := 'Standard';
            Rec.Statut::Loading:
                StatusStyleExpr := 'Attention';
            Rec.Statut::Stopped:
                StatusStyleExpr := 'Ambiguous';
            Rec.Statut::Inprogress:
                StatusStyleExpr := 'Favorable';
        end;
    end;
}