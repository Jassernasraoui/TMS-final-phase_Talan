page 73553 "Tour Execution Tracking Card"
{
    ApplicationArea = All;
    Caption = 'Fiche de Suivi d''Exécution';
    PageType = Card;
    SourceTable = "Tour Execution Tracking";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Général';

                field("Tour No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le numéro de la tournée associée.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le numéro de ligne de suivi.';
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le code du client pour cette livraison.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Affiche le nom du client pour cette livraison.';
                }
                field("Planning Line No."; Rec."Planning Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Référence à la ligne de planification originale.';
                    Visible = false;
                }
            }
            group("Delivery Information")
            {
                Caption = 'Informations de Livraison';

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le statut actuel de la livraison.';
                    StyleExpr = StyleExpr;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(StatusText; GetStatusText())
                {
                    ApplicationArea = All;
                    Caption = 'Statut Texte';
                    ToolTip = 'Affiche le texte descriptif du statut actuel de la livraison.';
                    Editable = false;
                    Style = Strong;
                }
                field(StatusDescription; GetStatusDescription())
                {
                    ApplicationArea = All;
                    Caption = 'Description du Statut';
                    ToolTip = 'Affiche une description détaillée du statut actuel de la livraison.';
                    Editable = false;
                    MultiLine = true;
                    Style = Attention;
                }
                field("Date Livraison"; Rec."Date Livraison")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la date à laquelle la livraison a été effectuée ou tentée.';
                }
                field("Heure Livraison"; Rec."Heure Livraison")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''heure à laquelle la livraison a été effectuée ou tentée.';
                }
                field("GPS Coordonnées"; Rec."GPS Coordonnées")
                {
                    ApplicationArea = All;
                    ToolTip = 'Affiche les coordonnées GPS enregistrées au moment de la livraison.';
                }
                field("Tournée Terminée"; Rec."Tournée Terminée")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique si la tournée associée est terminée.';
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique qui a dernièrement modifié cette entrée.';
                }
                field("Modified Date"; Rec."Modified Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique quand cette entrée a été dernièrement modifiée.';
                }
            }
            group(Notes)
            {
                Caption = 'Notes et Commentaires';

                field("Notes Livraison"; Rec."Notes Livraison")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Spécifie des notes ou commentaires concernant cette livraison.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ActivityLog; "Tour Activity Log ListPart")
            {
                ApplicationArea = All;
                Caption = 'Journal d''Activité';
                SubPageLink = "Tour No." = field("Tour No.");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Tour Card")
            {
                ApplicationArea = All;
                Caption = 'Fiche Tournée';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Planification Document";
                RunPageLink = "Logistic Tour No." = field("Tour No.");
                ToolTip = 'Affiche la fiche de planification de la tournée associée.';
            }
            action("Customer Card")
            {
                ApplicationArea = All;
                Caption = 'Fiche Client';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Customer No.");
                ToolTip = 'Affiche la fiche du client pour cette livraison.';
            }
        }
        area(Processing)
        {
            action(UpdateStatus)
            {
                ApplicationArea = All;
                Caption = 'Mettre à jour statut';
                Image = ChangeStatus;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Permet de mettre à jour le statut de livraison.';

                trigger OnAction()
                var
                    TourExecutionMgt: Codeunit "Tour Execution Mgt.";
                    StatusOptions: Text;
                    SelectedOption: Integer;
                begin
                    StatusOptions := 'En Attente,En Cours,Livré,Échoué,Reporté';
                    if Dialog.StrMenu(StatusOptions, SelectedOption, 'Sélectionnez le nouveau statut:') > 0 then begin
                        TourExecutionMgt.UpdateDeliveryStatus(Rec, SelectedOption - 1);  // Adjust for 0-based enum
                        CurrPage.Update(false);
                    end;
                end;
            }

            // action(CaptureSignature)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Capturer signature';
            //     Image = SignatureConfirmation;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ToolTip = 'Permet de capturer la signature du client.';

            //     trigger OnAction()
            //     var
            //         TourExecutionMgt: Codeunit "Tour Execution Mgt.";
            //         SignatureText: Text;
            //     begin
            //         if Dialog.TextBoxInput(SignatureText, 'Signature client', 'Saisir le nom du signataire:') then begin
            //             TourExecutionMgt.CaptureSignature(Rec, SignatureText);
            //             Message('Signature enregistrée.');
            //         end;
            //     end;
            // }
        }
        area(Reporting)
        {
            action("Print Delivery Slip")
            {
                ApplicationArea = All;
                Caption = 'Imprimer bon de livraison';
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Imprime un bon de livraison pour cette livraison.';

                trigger OnAction()
                begin
                    Message('Fonctionnalité en développement.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleExpr := GetStatusStyle();
    end;

    var
        StyleExpr: Text;

    local procedure GetStatusText(): Text
    begin
        case Rec.Status of
            Rec.Status::"En Attente":
                exit('En Attente de Livraison');
            Rec.Status::"En Cours":
                exit('Livraison En Cours');
            Rec.Status::"Livré":
                exit('Livraison Effectuée');
            Rec.Status::"Échoué":
                exit('Livraison Échouée');
            Rec.Status::"Reporté":
                exit('Livraison Reportée');
        end;
    end;

    local procedure GetStatusDescription(): Text
    begin
        case Rec.Status of
            Rec.Status::"En Attente":
                exit('La livraison est programmée mais n''a pas encore commencé. ' +
                     'Le chauffeur n''est pas encore arrivé chez ce client.');
            Rec.Status::"En Cours":
                exit('Le chauffeur est actuellement chez ce client et procède à la livraison. ' +
                     'Ce statut indique que la livraison est en train d''être effectuée.');
            Rec.Status::"Livré":
                exit('La livraison a été effectuée avec succès. ' +
                     'Les articles ont été remis au client et la livraison est considérée comme terminée.');
            Rec.Status::"Échoué":
                exit('La livraison n''a pas pu être effectuée. ' +
                     'Cela peut être dû à l''absence du client, un refus de livraison, ou d''autres problèmes. ' +
                     'Consultez les notes de livraison pour plus de détails.');
            Rec.Status::"Reporté":
                exit('La livraison a été reportée à une date ultérieure. ' +
                     'Cela peut être à la demande du client ou en raison de contraintes logistiques. ' +
                     'Consultez les notes de livraison pour connaître la raison du report.');
        end;
    end;

    local procedure GetStatusStyle(): Text
    begin
        case Rec.Status of
            Rec.Status::"En Attente":
                exit('Standard');
            Rec.Status::"En Cours":
                exit('Attention');
            Rec.Status::"Livré":
                exit('Favorable');
            Rec.Status::"Échoué":
                exit('Unfavorable');
            Rec.Status::"Reporté":
                exit('Ambiguous');
        end;
    end;
}