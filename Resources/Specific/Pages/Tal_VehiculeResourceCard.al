page 73504 " Tal Vehicule resources card "
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = Resource;
    Caption = 'Vehicule details and verification';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    // Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a description of the resource.';
                }
                field("Machine Model"; Rec."Machine Model")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the model of the vehicle.';
                }

                field(" License plate No."; rec." License plate No.")
                {
                    Tooltip = ' Specifies the vehicles registration number';
                    ApplicationArea = Jobs;
                }
                field(" Vehicule Insurance Security No."; rec." Vehicule Security No.")
                {
                    ToolTip = ' Specifies the Vehicule Security  number';
                    Caption = 'Vehicule Insurance Security No.';
                }
                field("Insurance Expiration Date "; rec."Insurance Expiration Date ")
                {
                    ToolTip = ' Specifies the expiration date of the vehicle insurance';
                    ApplicationArea = Jobs;
                }
                field(vignette; rec.vignette)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the vignette number of the vehicle.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = Jobs;
                    Importance = Additional;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the resource is a person or a machine.';
                    Editable = false;
                    trigger OnValidate()
                    begin
                        if Rec.Type = rec.type::Person then
                            Rec.Validate(Type, rec.Type::Machine);
                    end;

                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field("Resource Group No."; Rec."Resource Group No.")
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies the resource group that this resource is assigned to.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
                field("used as location"; Rec."used as location")

                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies whether the resource is a location or not.';
                }
                group("Vehicule Status")
                {
                    field("Vehicle Status"; rec."Resource Status")
                    {
                        ApplicationArea = jobs;
                        Caption = 'Vehicle Status';
                    }
                }

                group("Tour Statistics")
                {
                    Caption = 'Statistiques des Tournées';

                    field("Total Tours"; TotalTours)
                    {
                        ApplicationArea = All;
                        Caption = 'Nombre Total de Tournées';
                        ToolTip = 'Affiche le nombre total de tournées associées à ce véhicule.';
                        Editable = false;
                    }

                    field("Tours Plannified"; ToursPlannified)
                    {
                        ApplicationArea = All;
                        Caption = 'Tournées Planifiées';
                        ToolTip = 'Affiche le nombre de tournées planifiées pour ce véhicule.';
                        Editable = false;
                        StyleExpr = 'Favorable';
                    }

                    field("Tours Loading"; ToursLoading)
                    {
                        ApplicationArea = All;
                        Caption = 'Tournées en Chargement';
                        ToolTip = 'Affiche le nombre de tournées en cours de chargement pour ce véhicule.';
                        Editable = false;
                        StyleExpr = 'Attention';
                    }

                    field("Tours In Progress"; ToursInProgress)
                    {
                        ApplicationArea = All;
                        Caption = 'Tournées en Cours';
                        ToolTip = 'Affiche le nombre de tournées en cours pour ce véhicule.';
                        Editable = false;
                        StyleExpr = 'Favorable';
                    }

                    field("Tours Completed"; ToursCompleted)
                    {
                        ApplicationArea = All;
                        Caption = 'Tournées Terminées';
                        ToolTip = 'Affiche le nombre de tournées terminées pour ce véhicule.';
                        Editable = false;
                        StyleExpr = 'Favorable';
                    }

                    field("Tours Stopped"; ToursStopped)
                    {
                        ApplicationArea = All;
                        Caption = 'Tournées Arrêtées';
                        ToolTip = 'Affiche le nombre de tournées arrêtées pour ce véhicule.';
                        Editable = false;
                        StyleExpr = 'Unfavorable';
                    }
                }
            }
            group("Vehicle Type and size")
            {
                field("Vehicule Type"; Rec."vehicle Type")
                {
                    ApplicationArea = Jobs;
                }
                field("vehicle Volume"; rec."Vehicle Volume")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Vehicule Volume ( by m3 )';

                }
                field(IsTractor; Rec.IsTractor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether this vehicle is a tractor (powered unit).';

                }

                field("Tractor No."; Rec."Tractor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the tractor number if applicable.';
                    Editable = rec.IsTractor;
                }

                field(IsTrailer; Rec.IsTrailer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether this vehicle is a trailer (non-powered unit).';
                }

                field("Trailer No."; Rec."Trailer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the trailer number if applicable.';
                    Editable = rec.IsTrailer;
                }

                field(IsTanker; Rec.IsTanker)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether this vehicle is a tanker (for liquids/gases).';
                }

                field("Tanker No."; Rec."Tanker No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the tanker number if applicable.';
                    Editable = rec.IsTanker;
                }
            }

            group("Capacity")
            {
                field("Max Capacity Charge "; rec."Max Capacity Charge")
                {
                    ToolTip = ' Specifies the maximum load capacity of the vehicle in kilograms';
                    ApplicationArea = Jobs;
                }
                field("Current kilometres"; rec."Current kilometres")
                {
                    ToolTip = 'Indicates the total distance traveled by the vehicle ';
                    ApplicationArea = Jobs;
                }
                group("Vehicle Visits")
                {
                    field("Last Maintenance Date"; rec."Last Maintenance Date")
                    {
                        ToolTip = 'Specifies the Last Maintenance date of the vehicle statut';
                        ApplicationArea = Jobs;
                    }
                    field("Next Maintenance Date"; rec."Next Maintenance Date")
                    {
                        ToolTip = 'Specifies the next Maintenance date for the vehicle';
                        ApplicationArea = Jobs;
                    }
                }
            }

            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the cost of one unit of the selected item or resource.';
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the relationship between the Unit Cost, Unit Price, and Profit Percentage fields associated with this resource.';
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the profit margin that you want to sell the resource at. You can enter a profit percentage manually or have it entered according to the Price/Profit Calculation field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Jobs;
                    Importance = Promoted;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Default Deferral Template Code"; Rec."Default Deferral Template Code")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Default Deferral Template';
                    ToolTip = 'Specifies the default template that governs how to defer revenues and expenses to the periods when they occurred.';
                }
                field("Automatic Ext. Texts"; Rec."Automatic Ext. Texts")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies that an Extended Text Header will be added on sales or purchase documents for this resource.';
                }
                field("IC Partner Purch. G/L Acc. No."; Rec."IC Partner Purch. G/L Acc. No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the intercompany g/l account number in your partner''s company that the amount for this resource is posted to.';
                }
            }
        }
        area(factboxes)
        {
#if not CLEAN25
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::Resource), "No." = field("No.");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                UpdatePropagation = Both;
                SubPageLink = "Table ID" = const(Database::Resource), "No." = field("No.");
            }
            part(Control1906609707; "Resource Statistics FactBox")
            {
                ApplicationArea = Jobs;
                SubPageLink = "No." = field("No."),
                              "Chargeable Filter" = field("Chargeable Filter"),
#if not CLEAN25
                              "Service Zone Filter" = field("Service Zone Filter"),
#endif
                              "Unit of Measure Filter" = field("Unit of Measure Filter");
                Visible = true;
            }
            part(Control1907012907; "Resource Details FactBox")
            {
                ApplicationArea = Jobs;
                SubPageLink = "No." = field("No."),
                              "Chargeable Filter" = field("Chargeable Filter"),
#if not CLEAN25
                              "Service Zone Filter" = field("Service Zone Filter"),
#endif
                              "Unit of Measure Filter" = field("Unit of Measure Filter");
                Visible = true;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }


    }


    actions
    {
        area(Navigation)
        {
            action("Maintenance Planning")
            {
                ApplicationArea = All;
                Caption = 'Maintenance Planning';
                Image = Planning;
                ToolTip = 'Plan and schedule maintenance activities for the vehicle.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic for maintenance planning
                    Message('Maintenance planning initiated.');
                end;
            }

            action("Maintenance History")
            {
                ApplicationArea = All;
                Caption = 'Maintenance History';
                Image = History;
                ToolTip = 'View the history of maintenance activities for the vehicle.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic to display maintenance history
                    Message('Displaying maintenance history.');
                end;
            }

            action("Vehicle Maintenance KPI")
            {
                ApplicationArea = All;
                Caption = 'Vehicle Maintenance KPI';
                Image = Capacity;
                ToolTip = 'View key performance indicators related to vehicle maintenance.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic to display maintenance KPIs
                    Message('Displaying vehicle maintenance KPIs.');
                end;
            }

            action("Maintenance Dashboard")
            {
                ApplicationArea = All;
                Caption = 'Maintenance Dashboard';
                Image = AnalysisView;
                ToolTip = 'Access the dashboard for vehicle maintenance overview.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic to open maintenance dashboard
                    Message('Opening maintenance dashboard.');
                end;
            }

            action("Usage and Costs Report")
            {
                ApplicationArea = All;
                Caption = 'Usage and Costs Report';
                Image = Report;
                ToolTip = 'Generate a report on vehicle usage and associated costs.';
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic to generate usage and costs report
                    Message('Usage and costs report generated.');
                end;
            }

            action("Other Reports")
            {
                ApplicationArea = All;
                Caption = 'Other Reports';
                Image = Report;
                ToolTip = 'Access other reports related to the vehicle.';
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    // Add logic to display other reports
                    Message('Displaying other reports.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.Type <> Rec.Type::Machine then begin
            Rec.Type := Rec.Type::Machine;
            Rec.Modify(); // Enregistre la modification dans la base de données
        end;

        UpdateTourStatistics();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateTourStatistics();
    end;

    local procedure UpdateTourStatistics()
    var
        PlanificationHeader: Record "Planification Header";
    begin
        // Réinitialiser les compteurs
        TotalTours := 0;
        ToursPlannified := 0;
        ToursLoading := 0;
        ToursInProgress := 0;
        ToursCompleted := 0;
        ToursStopped := 0;

        // Compter toutes les tournées associées à ce véhicule
        PlanificationHeader.Reset();
        PlanificationHeader.SetRange("Véhicule No.", Rec."No.");
        TotalTours := PlanificationHeader.Count;

        // Compter les tournées par statut
        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Plannified);
        ToursPlannified := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Loading);
        ToursLoading := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Inprogress);
        ToursInProgress := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Completed);
        ToursCompleted := PlanificationHeader.Count;

        PlanificationHeader.SetRange(Statut, PlanificationHeader.Statut::Stopped);
        ToursStopped := PlanificationHeader.Count;
    end;

    var
        TotalTours: Integer;
        ToursPlannified: Integer;
        ToursLoading: Integer;
        ToursInProgress: Integer;
        ToursCompleted: Integer;
        ToursStopped: Integer;
}