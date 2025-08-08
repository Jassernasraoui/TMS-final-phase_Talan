page 73555 "Tour Execution Page"
{
    PageType = Document;
    SourceTable = "Tour Execution Tracking";
    SourceTableView = SORTING("Tour No.", "Line No.");
    Caption = 'Exécution de Tournée';
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(TourInfo)
            {
                Caption = 'Tour Information';

                field("Tour No."; rec."Tour No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour Number';
                    Style = StrongAccent;
                    StyleExpr = CurrentTourNoStyle;
                    ToolTip = 'Specifies the tour number to which documents will be added.';
                }
                field(TourStartDate; TourHeader."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour Start Date';
                    ToolTip = 'Specifies the start date of the tour.';
                }

                field(TourEndDate; TourHeader."End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour End Date';
                    ToolTip = 'Specifies the end date of the tour.';
                }

                field(TourStatus; TourStatus)
                {
                    Caption = 'Statut Tournée';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyleTxt;
                }

                field(DriverNo; DriverNo)
                {
                    Caption = 'Chauffeur';
                    ApplicationArea = All;
                    Editable = false;
                }

                field(VehiculeNo; VehiculeNo)
                {
                    Caption = 'Véhicule';
                    ApplicationArea = All;
                    Editable = false;
                }

                // Suppression du champ ExecutionMode qui n'est pas nécessaire
            }


            repeater(DeliveryStops)
            {
                Caption = 'Arrêts de Livraison';
                Editable = not IsNewTour;



                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro d''article à livrer';
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la description de l''article à livrer';
                    Editable = false;
                }
                field("Delivery Address"; Rec."Delivery Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''adresse de livraison';
                    Editable = false;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;

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
                    MultiLine = false;
                    Style = Attention;
                }

                field("Date Livraison"; Rec."Date Livraison")
                {
                    ApplicationArea = All;
                }

                field("Heure Livraison"; Rec."Heure Livraison")
                {
                    ApplicationArea = All;
                }

                field("Notes Livraison"; Rec."Notes Livraison")
                {
                    ApplicationArea = All;
                }

                field("Planned Quantity"; Rec."Planned Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie la quantité planifiée pour cette livraison.';
                }

                field("Quantity Delivered"; Rec."Quantity Delivered")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la quantité effectivement livrée au client.';
                    Editable = Rec.Status = Rec.Status::Livré;
                }

                field("Quantity Returned"; Rec."Quantity Returned")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Indique la quantité retournée (différence entre quantité planifiée et livrée).';
                    Style = Unfavorable;
                    StyleExpr = Rec."Quantity Returned" > 0;
                }

                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le motif du retour si des articles ont été retournés.';
                    Editable = Rec."Quantity Returned" > 0;
                }
            }

            group(ActivityLogs)
            {
                Caption = 'Journal d''Activités';

                part(LogsSubpage; "Tour Activity Logs Subpage")
                {
                    ApplicationArea = All;
                    SubPageLink = "Tour No." = FIELD("Tour No.");
                    UpdatePropagation = Both;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitiateTourExecution)
            {
                Caption = 'Start Execution';
                ApplicationArea = All;
                Image = Start;
                Enabled = IsNewTour AND (TourNo <> '');
                Promoted = true;

                trigger OnAction()
                var
                    TMSProcessFlow: Codeunit "Tour Execution Management";
                begin
                    if not Confirm('Do you want to start execution of tour %1?', false, TourNo) then
                        exit;

                    TMSProcessFlow.InitializeTourExecution(TourNo);
                    CurrPage.Update(false);
                end;
            }

            action(DeliverStop)
            {
                Caption = 'Marquer Livré';
                ApplicationArea = All;
                Promoted = true;

                Image = Completed;
                Enabled = not IsNewTour AND (Rec.Status <> Rec.Status::Livré);

                trigger OnAction()
                var
                    ExecutionMgt: Codeunit "Tour Execution Management";
                    Notes: Text[250];
                    QuantityDelivered: Decimal;
                    ReturnReasonCode: Code[20];
                begin
                    if not Confirm('Marquer l''arrêt %1 comme livré?', false, Rec."Line No.") then
                        exit;

                    if InputText('Notes de Livraison', 'Entrez les notes de livraison (optionnel):', Notes) then;

                    ExecutionMgt.UpdateStopStatus(Rec."Tour No.", Rec."Line No.", Rec.Status::Livré, Notes);
                    CurrPage.Update(false);
                end;
            }

            action(FailStop)
            {
                Caption = 'Marquer Échec';
                Promoted = true;

                ApplicationArea = All;
                Image = Cancel;
                Enabled = not IsNewTour AND (Rec.Status <> Rec.Status::Échoué);

                trigger OnAction()
                var
                    ExecutionMgt: Codeunit "Tour Execution Management";
                    Notes: Text[250];
                begin
                    if not Confirm('Marquer l''arrêt %1 comme échoué?', false, Rec."Line No.") then
                        exit;

                    if not InputText('Raison de l''Échec', 'Entrez la raison de l''échec (obligatoire):', Notes) then
                        Error('Vous devez indiquer la raison de l''échec');

                    ExecutionMgt.UpdateStopStatus(Rec."Tour No.", Rec."Line No.", Rec.Status::Échoué, Notes);
                    CurrPage.Update(false);
                end;
            }

            action(PostponeStop)
            {
                Caption = 'Reporter';
                Promoted = true;

                ApplicationArea = All;
                Image = PostponedInteractions;
                Enabled = not IsNewTour AND (Rec.Status <> Rec.Status::Reporté);

                trigger OnAction()
                var
                    ExecutionMgt: Codeunit "Tour Execution Management";
                    Notes: Text[250];
                begin
                    if not Confirm('Reporter l''arrêt %1?', false, Rec."Line No.") then
                        exit;

                    if not InputText('Raison du Report', 'Entrez la raison du report (obligatoire):', Notes) then
                        Error('Vous devez indiquer la raison du report');

                    ExecutionMgt.UpdateStopStatus(Rec."Tour No.", Rec."Line No.", Rec.Status::Reporté, Notes);
                    CurrPage.Update(false);
                end;
            }

            action(InProgressStop)
            {
                Caption = 'Marquer En Cours';
                Promoted = true;

                ApplicationArea = All;
                Image = InProgress;
                Enabled = not IsNewTour AND (Rec.Status = Rec.Status::"En Attente");

                trigger OnAction()
                var
                    ExecutionMgt: Codeunit "Tour Execution Management";
                begin
                    if not Confirm('Marquer l''arrêt %1 comme en cours?', false, Rec."Line No.") then
                        exit;

                    ExecutionMgt.UpdateStopStatus(Rec."Tour No.", Rec."Line No.", Rec.Status::"En Cours", '');
                    CurrPage.Update(false);
                end;
            }

            action(CompleteTour)
            {
                Caption = 'Terminer Tournée';
                Promoted = true;

                ApplicationArea = All;
                Image = Close;
                Enabled = not IsNewTour;

                trigger OnAction()
                var
                    ExecutionMgt: Codeunit "Tour Execution Management";
                    Notes: Text[250];
                begin
                    if not Confirm('Êtes-vous sûr de vouloir terminer la tournée %1?', false, TourNo) then
                        exit;

                    if InputText('Notes de Clôture', 'Entrez les notes de clôture (optionnel):', Notes) then;

                    ExecutionMgt.CompleteTour(TourNo, Notes);
                    Message('La tournée %1 a été terminée avec succès.', TourNo);
                    IsNewTour := true;
                    TourNo := '';
                    CurrPage.Update(false);
                end;
            }

            action(RefreshTour)
            {
                Caption = 'Actualiser';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                begin
                    if TourNo <> '' then
                        LoadTourInfo();

                    CurrPage.Update(false);
                end;
            }

            action("Go to Execution")
            {
                ApplicationArea = All;
                Caption = 'Go to Execution';
                Image = Next;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                var
                    TourExecutionRec: Record "Tour Execution Tracking";
                    TourHeader: Record "Planification Header";
                    VehicleChargingHeader: Record "Vehicle Charging Header";
                    ChargingCompleted: Boolean;
                begin
                    // Check if there is a charging document for this tour that is completed
                    ChargingCompleted := false;
                    if TourHeader.Get(Rec."Tour No.") then begin
                        VehicleChargingHeader.Reset();
                        VehicleChargingHeader.SetRange("Tour No.", Rec."Tour No.");
                        VehicleChargingHeader.SetRange(Status, VehicleChargingHeader.Status::Completed);
                        ChargingCompleted := not VehicleChargingHeader.IsEmpty();
                    end;

                    if not ChargingCompleted then begin
                        Message('The charging phase must be completed before proceeding to execution.');
                        exit;
                    end;

                    // Filter the execution record to the current tour
                    TourExecutionRec.SetRange("Tour No.", rec."Tour No.");

                    // Open the execution page for this tour, passing the filtered record
                    PAGE.Run(PAGE::"Tour Execution Page", TourExecutionRec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsNewTour := true;
        ClearVariables();

        if Rec.FindFirst() then begin
            TourNo := Rec."Tour No.";
            IsNewTour := false;
            LoadTourInfo();
        end else if TourNoParam <> '' then begin
            TourNo := TourNoParam;
            LoadTourInfo();
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    var
        TourNo: Code[20];
        TourStatus: Text[50];
        TourDate: Date;
        DriverNo: Code[20];
        VehiculeNo: Code[20];
        IsNewTour: Boolean;
        // Suppression de la variable ExecutionMode
        StatusStyleTxt: Text;
        StatusStyleExpr: Text;
        CurrentTourNo: Code[20];
        CurrentTourNoStyle: Boolean;
        TourHeader: Record "Planification Header";
        DateFilterStart: Date;
        DateFilterEnd: Date;
        TourNoParam: Code[20];

    procedure SetTourHeader(TourHeaderRec: Record "Planification Header")
    begin
        // Store the tour header
        TourHeader := TourHeaderRec;

        // Set the global tour number variable directly
        CurrentTourNo := TourHeaderRec."Logistic Tour No.";
        CurrentTourNoStyle := true;

        // Set default date filters if available
        if TourHeader."Start Date" <> 0D then
            DateFilterStart := TourHeader."Start Date";

        if TourHeader."End Date" <> 0D then
            DateFilterEnd := TourHeader."End Date";

        // Load documents with this tour number
    end;

    local procedure ClearVariables()
    begin
        TourNo := '';
        TourStatus := '';
        TourDate := 0D;
        DriverNo := '';
        VehiculeNo := '';
        // Suppression de la ligne ExecutionMode
        StatusStyleTxt := '';
    end;

    local procedure LoadTourInfo()
    var
        PlanificationHeader: Record "Planification Header";
    begin
        ClearVariables();

        // If TourNo is empty, try to get it from the current record
        if TourNo = '' then
            if Rec."Tour No." <> '' then
                TourNo := Rec."Tour No.";

        if TourNo = '' then
            exit;

        if PlanificationHeader.Get(TourNo) then begin
            TourStatus := Format(PlanificationHeader.Statut);
            TourDate := PlanificationHeader."Date de Tournée";
            DriverNo := PlanificationHeader."Driver No.";
            VehiculeNo := PlanificationHeader."Véhicule No.";

            case PlanificationHeader.Statut of
                PlanificationHeader.Statut::Plannified:
                    begin
                        StatusStyleTxt := 'Favorable';
                    end;
                PlanificationHeader.Statut::Loading:
                    begin
                        StatusStyleTxt := 'Attention';
                    end;
                PlanificationHeader.Statut::Inprogress:
                    begin
                        StatusStyleTxt := 'Favorable';
                        IsNewTour := false;
                        // Charger les lignes de suivi
                        Rec.Reset();
                        Rec.SetRange("Tour No.", TourNo);
                        if not Rec.FindFirst() then
                            Message('Aucune ligne de suivi trouvée pour la tournée %1.', TourNo);
                    end;
                PlanificationHeader.Statut::Stopped:
                    begin
                        StatusStyleTxt := 'Unfavorable';
                        Message('La tournée %1 est déjà terminée.', TourNo);
                    end;
            end;
        end else begin
            Message('La tournée %1 n''existe pas.', TourNo);
            TourNo := '';
        end;
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::"En Attente":
                StatusStyleExpr := 'Ambiguous';
            Rec.Status::"En Cours":
                StatusStyleExpr := 'Attention';
            Rec.Status::"Livré":
                StatusStyleExpr := 'Favorable';
            Rec.Status::"Échoué":
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Reporté":
                StatusStyleExpr := 'Subordinate';
        end;
    end;

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

    local procedure InputText(TitleTxt: Text[100]; PromptTxt: Text[250]; var ResultTxt: Text[250]): Boolean
    var
        InputDialog: Page "Input Dialog";
    begin
        InputDialog.SetTexts(TitleTxt, PromptTxt);
        if InputDialog.RunModal() = ACTION::OK then begin
            ResultTxt := InputDialog.GetInput();
            exit(true);
        end;
        exit(false);
    end;

    procedure InputDecimal(TitleTxt: Text[100]; PromptTxt: Text[250]; var ResultDecimal: Decimal): Boolean
    var
        InputDialog: Page "Input Dialog";
        ResultTxt: Text[250];
    begin
        ResultTxt := Format(ResultDecimal);
        InputDialog.SetTexts(TitleTxt, PromptTxt);
        // InputDialog.SetInput(ResultTxt); // This method doesn't exist
        if InputDialog.RunModal() = ACTION::OK then begin
            ResultTxt := InputDialog.GetInput();
            Evaluate(ResultDecimal, ResultTxt);
            exit(true);
        end;
        exit(false);
    end;

    procedure GetQuantityDelivered(TitleTxt: Text[100]; PromptTxt: Text[250]; var ResultDecimal: Decimal): Boolean
    begin
        exit(InputDecimal(TitleTxt, PromptTxt, ResultDecimal));
    end;

    procedure GetReturnReason(TitleTxt: Text[100]; PromptTxt: Text[250]; var ResultText: Code[20]): Boolean
    var
        TempText: Text[250];
    begin
        TempText := ResultText;
        if InputText(TitleTxt, PromptTxt, TempText) then begin
            ResultText := CopyStr(TempText, 1, MaxStrLen(ResultText));
            exit(true);
        end;
        exit(false);
    end;

    procedure SetTourNo(TourNoInput: Code[20])
    begin
        TourNoParam := TourNoInput;
    end;
}