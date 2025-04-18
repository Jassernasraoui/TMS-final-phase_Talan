page 50119 "Planification Document"
{
    PageType = document;
    SourceTable = "Planification Header";
    ApplicationArea = All;
    Caption = 'Tournee File ';
    //ultipleNewLines = true;
    // SourceTableView = where("Document Type" = filter(Order));
    // RefreshOnActivate = true;


    layout
    {
        area(content)
        {
            group("General")
            {
                field("Tour No."; Rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    Caption = 'Logistic Tour No ';
                }
                field("Created By"; rec."Created By")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    LookupPageId = "Users";
                    ToolTip = 'Specifies the user''s name. If the user is required to present credentials when starting the client, this is the name that the user must present.';

                }
                field("Delivery Area"; rec."Delivery Area")
                {
                    ;
                }

                field("Tour Start Date"; Rec."Date de Tournée")
                {
                    ApplicationArea = All;
                }
                field("Estimated Distance (km)"; Rec."Estimated Distance")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Estimated Duration (hrs)"; Rec."Estimated Duration")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Estimated Total Weight"; Rec."Estimated Total Weight")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "Resource List";
                }

                field("Véhicule No."; Rec."Véhicule No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "Vehicule Resource list"; // Page standard de véhicules
                }

                field("Statut"; Rec."Statut")
                {
                    ApplicationArea = All;
                }
            }

            part("Tour Planning Line"; "Planning Lines ListPart")
            {
                SubPageLink = "Logistic Tour No." = field("Logistic Tour No.");
                ApplicationArea = Basic, Suite;
                // Editable = false;
                // // SubPageLink = "Document No." = field("No.");
                // // UpdatePropagation = Both;
            }

        }




    }
    actions
    {
        area(Processing)
        {
            group("Fetch Planning Lines")
            {
                action("Get Sales Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Get Sales Lines';
                    Image = Import;

                    trigger OnAction()
                    var
                        PlanningLineFetcher: Codeunit "Planning Line Fetcher";
                    begin
                        PlanningLineFetcher.FetchSalesLines(Rec."No.");
                        CurrPage.Update(); // Pour rafraîchir le subform
                    end;
                }

                action("Get Purchase Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Get Purchase Lines';
                    Image = Import;

                    trigger OnAction()
                    var
                        PlanningLineFetcher: Codeunit "Planning Line Fetcher";
                    begin
                        PlanningLineFetcher.FetchPurchaseLines(Rec."No.");
                        CurrPage.Update(); // Pour rafraîchir le subform
                    end;
                }

                action("Get Transfer Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Get Transfer Lines';
                    Image = Import;

                    trigger OnAction()
                    var
                        PlanningLineFetcher: Codeunit "Planning Line Fetcher";
                    begin
                        PlanningLineFetcher.FetchTransferLines(Rec."No.");
                        CurrPage.Update(); // Pour rafraîchir le subform
                    end;
                }
            }
        }
        area(Navigation)
    {
        action("Create Vehicle Loading")
        {
            Caption = 'Create Vehicle Loading';
            ApplicationArea = All;
            Image = Add;

            trigger OnAction()
            var
                VehicleLoadingRec: Record "Vehicle Loading";
                VehicleLoadingPage: Page "Vehicle Loading Card";
            begin
                VehicleLoadingRec.Init();
                VehicleLoadingRec."Loading Date" := Today;
                VehicleLoadingRec."Vehicle No." := Rec."Véhicule No.";
                VehicleLoadingRec."Driver Name" := Rec."Driver No.";
                VehicleLoadingRec.Insert(true); // true = run trigger

                // Ouvrir la page carte avec l’enregistrement nouvellement créé
                VehicleLoadingPage.SetRecord(VehicleLoadingRec);
                VehicleLoadingPage.Run();
            end;
        }
    }
    }







}

