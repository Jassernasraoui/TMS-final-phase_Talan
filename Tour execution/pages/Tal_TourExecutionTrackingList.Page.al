page 77052 "Tour Execution Tracking List"
{
    ApplicationArea = All;
    Caption = 'Suivi d''Exécution de Tournée';
    PageType = List;
    SourceTable = "Tour Execution Tracking";
    UsageCategory = Lists;
    CardPageId = "Tour Execution Tracking Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Tour No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro de la tournée associée.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le code du client pour cette livraison.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Affiche le nom du client pour cette livraison.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le statut actuel de la livraison.';
                    StyleExpr = StyleExpr;
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
                field("Notes Livraison"; Rec."Notes Livraison")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie des notes ou commentaires concernant cette livraison.';
                }
                field("GPS Coordonnées"; Rec."GPS Coordonnées")
                {
                    ApplicationArea = All;
                    ToolTip = 'Affiche les coordonnées GPS enregistrées au moment de la livraison.';
                    Visible = false;
                }
                field("Tournée Terminée"; Rec."Tournée Terminée")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indique si la tournée associée est terminée.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(TourDetails; "Tour Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Logistic Tour No." = field("Tour No.");
                Caption = 'Détails de la Tournée';
                Visible = false;
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
                RunObject = Page "Planification Document";
                RunPageLink = "Logistic Tour No." = field("Tour No.");
                ToolTip = 'Affiche la fiche de planification de la tournée associée.';
            }
            action("Tour Activity Log")
            {
                ApplicationArea = All;
                Caption = 'Journal d''Activité';
                Image = Log;
                RunObject = Page "Tour Activity Log List";
                RunPageLink = "Tour No." = field("Tour No.");
                ToolTip = 'Affiche le journal des activités pour cette tournée.';
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

            // action(AddNote)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Ajouter note';
            //     Image = Note;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ToolTip = 'Permet d''ajouter une note à cette livraison.';

            //     trigger OnAction()
            //     var
            //         TourExecutionMgt: Codeunit "Tour Execution Mgt.";
            //         NoteText: Text[250];
            //     begin
            //         if Dialog.TextBoxInput(NoteText, 'Note de livraison', 'Saisir une note pour cette livraison:') then begin
            //             TourExecutionMgt.AddDeliveryNote(Rec, NoteText);
            //             CurrPage.Update(false);
            //         end;
            //     end;
            // }

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

            // action(RecordGPS)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Enregistrer position GPS';
            //     Image = MapPoint;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ToolTip = 'Permet d''enregistrer la position GPS actuelle.';

            //     trigger OnAction()
            //     var
            //         TourExecutionMgt: Codeunit "Tour Execution Mgt.";
            //         GPSCoords: Text[50];
            //     begin
            //         if Dialog.TextBoxInput(GPSCoords, 'Coordonnées GPS', 'Saisir les coordonnées GPS:') then begin
            //             TourExecutionMgt.RecordGPSLocation(Rec, GPSCoords);
            //             Message('Position GPS enregistrée.');
            //         end;
            //     end;
            // }
        }
        area(Reporting)
        {
            action("Delivery Report")
            {
                ApplicationArea = All;
                Caption = 'Rapport livraison';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'Génère un rapport détaillé de livraison.';

                trigger OnAction()
                begin
                    // This will be implemented when the report is created
                    Message('Rapport en cours de développement.');
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