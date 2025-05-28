page 77055 "Tour Execution Page"
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



                field(ExecutionMode; ExecutionMode)
                {
                    Caption = 'Mode d''Exécution';
                    ApplicationArea = All;
                    Editable = IsNewTour AND (TourNo <> '');
                }
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

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;
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
        ExecutionMode: Option FromPlanning,FromLoading;
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
        ExecutionMode := ExecutionMode::FromPlanning;
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
                        ExecutionMode := ExecutionMode::FromPlanning;
                    end;
                PlanificationHeader.Statut::Loading:
                    begin
                        StatusStyleTxt := 'Attention';
                        ExecutionMode := ExecutionMode::FromLoading;
                    end;
                PlanificationHeader.Statut::EnCours:
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
                StatusStyleExpr := 'Subordinate';
            Rec.Status::"En Cours":
                StatusStyleExpr := 'Attention';
            Rec.Status::Livré:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Échoué:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::Reporté:
                StatusStyleExpr := 'Ambiguous';
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

    procedure SetTourNo(TourNoInput: Code[20])
    begin
        TourNoParam := TourNoInput;
    end;
}