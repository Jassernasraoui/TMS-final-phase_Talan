page 73507 "Planification Document"
{
    PageType = document;
    SourceTable = "Planification Header";
    ApplicationArea = All;
    Caption = 'Tour Planning';
    //multipleNewLines = true;
    // SourceTableView = where("Document Type" = filter(Order));
    // RefreshOnActivate = true;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Logistic Tour No."; Rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sélectionnez un numéro généré automatiquement à partir de la série.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }


                field("Statut"; Rec."Statut")
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the current status of the tour.';
                    Importance = Promoted;
                    StyleExpr = StatusStyleExpr;
                }

                field("Created By"; rec."Created By")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    LookupPageId = "Users";
                    ToolTip = 'Specifies the user that created this tour.';
                    Editable = false;
                }

                field("Document Date"; rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the date when the document was created.';
                    Editable = false;
                }
            }

            group("Time Interval")
            {
                Caption = 'Planning Interval';

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date of the planning interval.';
                    Importance = Promoted;
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date of the planning interval.';
                    Importance = Promoted;
                }

                field("Working Hours Start"; Rec."Working Hours Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the starting time of working hours for each day.';
                    Visible = false;
                }

                field("Working Hours End"; Rec."Working Hours End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ending time of working hours for each day.';
                    Visible = false;
                }

                field("Max Visits Per Tour"; Rec."Max Visits Per Tour")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of visits allowed per day.';
                }


            }

            group("Resources")
            {
                Caption = 'Resources & Location';
                group(Ressources)
                {

                    field("Driver No."; Rec."Driver No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Driver/Technician';
                        LookupPageId = "Resource List";
                        ToolTip = 'Specifies the driver or technician assigned to this tour.';
                    }
                    field("Conveyor Attendant"; Rec."Conveyor Attendant")
                    {
                        ApplicationArea = All;
                        Caption = 'Conveyor Attendant';
                        LookupPageId = "Resource List";
                        ToolTip = 'Specifies the conveyor attendant assigned to this tour.';

                    }

                    field("Véhicule No."; Rec."Véhicule No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Vehicle';
                        LookupPageId = "Tal Vehicule Resource list";
                        ToolTip = 'Specifies the vehicle assigned to this tour.';
                    }
                }
                group(Location)
                {

                    field("Start Location"; Rec."Start Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the starting location for the tour.';
                        Editable = false;

                        trigger OnValidate()
                        var
                            PlanningLine: Record "Planning Lines";
                            Location: Record Location;
                            NextLineNo: Integer;
                            ConfirmManagement: Codeunit "Confirm Management";
                        begin
                            if xRec."Start Location" <> Rec."Start Location" then begin
                                if Rec."Start Location" <> '' then begin
                                    if ConfirmManagement.GetResponseOrDefault('Do you want to add the start location to the planning lines?', true) then begin
                                        // Find if there's already a planning line marked as start location
                                        PlanningLine.Reset();
                                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                        PlanningLine.SetRange("Is Start Location", true);

                                        if PlanningLine.FindFirst() then begin
                                            // Update existing start location line
                                            if Location.Get(Rec."Start Location") then begin
                                                PlanningLine."Location Code" := Location.Code;
                                                PlanningLine.Description := 'Start Location: ' + Location.Name;
                                                PlanningLine.Address := Location.Address;
                                                PlanningLine.City := Location.City;
                                                PlanningLine."State (County)" := Location."Post Code";
                                                PlanningLine."Country/Region Code" := Location."Country/Region Code";
                                                PlanningLine.Modify();
                                            end;
                                        end else begin
                                            // Create new planning line for start location
                                            // Find the next line number
                                            PlanningLine.Reset();
                                            PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                            if PlanningLine.FindLast() then
                                                NextLineNo := PlanningLine."Line No." + 10000
                                            else
                                                NextLineNo := 10000;

                                            if Location.Get(Rec."Start Location") then begin
                                                PlanningLine.Init();
                                                PlanningLine."Logistic Tour No." := Rec."Logistic Tour No.";
                                                PlanningLine."Line No." := NextLineNo;
                                                PlanningLine."Type" := PlanningLine."Type"::Transfer;
                                                PlanningLine."Location Code" := Location.Code;
                                                PlanningLine.Description := 'Start Location: ' + Location.Name;
                                                PlanningLine.Address := Location.Address;
                                                PlanningLine.City := Location.City;
                                                PlanningLine."State (County)" := Location."Post Code";
                                                PlanningLine."Country/Region Code" := Location."Country/Region Code";
                                                PlanningLine."Is Start Location" := true;
                                                PlanningLine."Priority" := PlanningLine."Priority"::Critical;
                                                PlanningLine.Insert();
                                            end;
                                        end;
                                    end;
                                end else begin
                                    // Remove start location flag from any planning lines if the start location is cleared
                                    PlanningLine.Reset();
                                    PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                    PlanningLine.SetRange("Is Start Location", true);
                                    if PlanningLine.FindSet() then begin
                                        repeat
                                            PlanningLine."Is Start Location" := false;
                                            PlanningLine.Modify();
                                        until PlanningLine.Next() = 0;
                                    end;
                                end;
                            end;
                        end;
                    }

                    field("End Location"; Rec."End Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ending location for the tour.';
                        Editable = false;

                        trigger OnValidate()
                        var
                            PlanningLine: Record "Planning Lines";
                            Location: Record Location;
                            NextLineNo: Integer;
                            ConfirmManagement: Codeunit "Confirm Management";
                        begin
                            if xRec."End Location" <> Rec."End Location" then begin
                                if Rec."End Location" <> '' then begin
                                    if ConfirmManagement.GetResponseOrDefault('Do you want to add the end location to the planning lines?', true) then begin
                                        // Find if there's already a planning line marked as end location
                                        PlanningLine.Reset();
                                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                        PlanningLine.SetRange("Is End Location", true);

                                        if PlanningLine.FindFirst() then begin
                                            // Update existing end location line
                                            if Location.Get(Rec."End Location") then begin
                                                PlanningLine."Location Code" := Location.Code;
                                                PlanningLine.Description := 'End Location: ' + Location.Name;
                                                PlanningLine.Address := Location.Address;
                                                PlanningLine.City := Location.City;
                                                PlanningLine."State (County)" := Location."Post Code";
                                                PlanningLine."Country/Region Code" := Location."Country/Region Code";
                                                PlanningLine.Modify();
                                            end;
                                        end else begin
                                            // Create new planning line for end location
                                            // Find the next line number
                                            PlanningLine.Reset();
                                            PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                            if PlanningLine.FindLast() then
                                                NextLineNo := PlanningLine."Line No." + 10000
                                            else
                                                NextLineNo := 10000;

                                            if Location.Get(Rec."End Location") then begin
                                                PlanningLine.Init();
                                                PlanningLine."Logistic Tour No." := Rec."Logistic Tour No.";
                                                PlanningLine."Line No." := NextLineNo;
                                                PlanningLine."Type" := PlanningLine."Type"::Transfer;
                                                PlanningLine."Location Code" := Location.Code;
                                                PlanningLine.Description := 'End Location: ' + Location.Name;
                                                PlanningLine.Address := Location.Address;
                                                PlanningLine.City := Location.City;
                                                PlanningLine."State (County)" := Location."Post Code";
                                                PlanningLine."Country/Region Code" := Location."Country/Region Code";
                                                PlanningLine."Is End Location" := true;
                                                PlanningLine."Priority" := PlanningLine."Priority"::Critical;
                                                PlanningLine.Insert();
                                            end;
                                        end;
                                    end;
                                end else begin
                                    // Remove end location flag from any planning lines if the end location is cleared
                                    PlanningLine.Reset();
                                    PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                                    PlanningLine.SetRange("Is End Location", true);
                                    if PlanningLine.FindSet() then begin
                                        repeat
                                            PlanningLine."Is End Location" := false;
                                            PlanningLine.Modify();
                                        until PlanningLine.Next() = 0;
                                    end;
                                end;
                            end;
                        end;
                    }
                }
                field("Non-Working Days"; Rec."Non-Working Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the days to exclude from planning (format: DD/MM/YYYY, comma-separated).';
                    MultiLine = true;
                    Visible = false;
                }

                // field("Delivery Area"; rec."Delivery Area")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Delivery Area';
                //     ToolTip = 'Specifies the geographic area for deliveries.';


                // }
            }
            part("Tour Planning Lines"; "Planning Lines")
            {
                Caption = 'Planning Lines';
                SubPageLink = "Logistic Tour No." = field("Logistic Tour No.");
                ApplicationArea = Basic, Suite;
                Editable = true;
            }

            group("Logistics Details")
            {
                Caption = 'Logistics Details';

                field("Shipping Agent"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent';
                    LookupPageId = "Shipping Agents";
                    ToolTip = 'Specifies the shipping agent for the tour.';
                }

                field("Warehouse Location"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Warehouse Location';
                    LookupPageId = "Location list";
                    Editable = false;
                    ToolTip = 'Specifies the warehouse location for the tour.';
                }

                field("Warehouse employees"; Rec."Warehouse Employees")
                {
                    ApplicationArea = All;
                    Caption = 'Warehouse Employee';
                    LookupPageId = "Warehouse Employees";
                    ToolTip = 'Specifies the warehouse employee responsible for the tour.';
                    visible = false;
                }
                field("Number of Deliveries"; rec."Number of Deliveries")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Number of Deliveries';
                    Visible = true;
                }


                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    ToolTip = 'Specifies the total quantity of all planning lines.';
                    Editable = false;
                    Visible = false;
                }

                field("Estimated Total Weight"; Rec."Estimated Total Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Total Weight (kg)';
                    Editable = false;
                    ToolTip = 'Shows the estimated total weight for all items in this tour.';
                    trigger OnValidate()
                    var
                        PlanningLine: Record "Planning Lines";
                        TotalWeight: Decimal;
                    begin

                    end;
                }

                field("Estimated Distance"; Rec."Estimated Distance")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Distance (km)';
                    Editable = false;
                    ToolTip = 'Shows the estimated total distance for this tour.';
                }

                field("Estimated Duration"; Rec."Estimated Duration")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Duration (hrs)';
                    Editable = false;
                    ToolTip = 'Shows the estimated total duration for this tour.';
                }
            }



            // part("Daily Schedule"; "Daily Schedule ListPart")
            // {
            //     Caption = 'Daily Schedule';
            //     SubPageLink = "Logistic Tour No." = field("Logistic Tour No.");
            //     ApplicationArea = Basic, Suite;
            //     Editable = true;
            //     Visible = true;
            // }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Source Documents")
            {
                Caption = 'Source Documents';
                Image = Documents;

                action("Extract Source Documents")
                {
                    ApplicationArea = All;
                    Caption = 'Extract Source Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Extract documents to include in this tour.';

                    trigger OnAction()
                    begin
                        OpenSourceDocumentSelection();
                    end;
                }


                action("Get Sales Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Get Sales Orders';
                    Image = Sales;
                    ToolTip = 'Extracts sales orders for this tour.';

                    trigger OnAction()
                    begin
                        GetSalesOrdersForPlanning();
                    end;
                }

                action("Get Purchase Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Get Purchase Orders';
                    Image = Purchase;
                    ToolTip = 'Extracts purchase orders for this tour.';

                    trigger OnAction()
                    begin
                        GetPurchaseOrdersForPlanning();
                    end;
                }

                action("Get Transfer Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Get Transfer Orders';
                    Image = TransferOrder;
                    ToolTip = 'Extracts transfer orders for this tour.';

                    trigger OnAction()
                    begin
                        GetTransferOrdersForPlanning();
                    end;
                }


                group("Planning Tools")
                {
                    Caption = 'Planning Tools';
                    Image = Planning;

                    // action("Auto-Assign Days")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Auto-Assign Days';
                    //     Image = Calendar;
                    //     ToolTip = 'Intelligemment répartit les lignes de planification sur les jours disponibles de la tournée en tenant compte des dates prévues, des priorités, et des regroupements par emplacement. Propose des suggestions avant d''appliquer les changements.';

                    //     trigger OnAction()
                    //     begin
                    //         AutoAssignDays();
                    //     end;
                    // }

                    action("Group By Proximity")
                    {
                        ApplicationArea = All;
                        Caption = 'Group By Proximity';
                        Image = Group;
                        ToolTip = 'Groups missions by geographic proximity.';

                        trigger OnAction()
                        begin
                            GroupByProximity();
                        end;
                    }

                    action("Group By Customer")
                    {
                        ApplicationArea = All;
                        Caption = 'Group By Customer';
                        Image = Customer;
                        ToolTip = 'Groups missions by customer.';

                        trigger OnAction()
                        begin
                            GroupByCustomer();
                        end;
                    }

                    action("Group By Activity Type")
                    {
                        ApplicationArea = All;
                        Caption = 'Group By Activity Type';
                        Image = WorkCenterLoad;
                        ToolTip = 'Groups missions by activity type.';

                        trigger OnAction()
                        begin
                            GroupByActivityType();
                        end;
                    }

                    action("Balance Workload")
                    {
                        ApplicationArea = All;
                        Caption = 'Balance Workload';
                        Image = Balance;
                        ToolTip = 'Balances the workload across all planning days.';

                        trigger OnAction()
                        begin
                            BalanceWorkload();
                        end;
                    }

                    // action("Optimize Routes")
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Optimize Routes';
                    //     Image = Route;
                    //     ToolTip = 'Optimizes daily routes to minimize travel time.';

                    //     trigger OnAction()
                    //     begin
                    //         OptimizeRoutes();
                    //     end;
                    // }
                }

                group("Views")
                {
                    Caption = 'Views';
                    Image = View;

                    action("Calendar View")
                    {
                        ApplicationArea = All;
                        Caption = 'Calendar View';
                        Image = Calendar;
                        ToolTip = 'View the planning in a calendar format.';

                        trigger OnAction()
                        begin
                            ShowCalendarView();
                        end;
                    }

                    action("Show on Google Maps")
                    {
                        Caption = 'Show on Google Maps';
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            Place: Text;
                            EncodedPlace: Text;
                            URL: Text;
                        begin
                            Place := Rec."Delivery Area"; // Replace with your actual field name
                            EncodedPlace := Place.Replace(' ', '%20'); // Replace spaces with %20
                            URL := 'https://www.google.com/maps/search/?api=1&query=' + EncodedPlace;
                            HYPERLINK(URL);
                        end;
                    }




                    action("Route Overview")
                    {
                        ApplicationArea = All;
                        Caption = 'Show All on Map';
                        Image = Map;
                        trigger OnAction()
                        var
                            PlanningLine: Record "Planning Lines";
                            OnlineMapIntegration: Codeunit "Online Map Integration";
                            Customer: Record Customer;
                            Vendor: Record Vendor;
                            Location: Record Location;
                            SalesHeader: Record "Sales Header";
                            PurchaseHeader: Record "Purchase Header";
                            TransferHeader: Record "Transfer Header";
                            ShipToAddress: Record "Ship-to Address";
                            LocationsList: Text;
                            MapUrl: Text;
                            Address: Text;
                            City: Text;
                            PostCode: Text;
                            CountryCode: Text;
                            Latitude: Text;
                            Longitude: Text;
                            LocationName: Text;
                            LocationCount: Integer;
                        begin
                            LocationsList := '';
                            LocationCount := 0;

                            // Get all planning lines
                            PlanningLine.Reset();
                            PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");

                            if PlanningLine.FindSet() then begin
                                repeat
                                    Clear(Address);
                                    Clear(City);
                                    Clear(PostCode);
                                    Clear(CountryCode);
                                    Clear(Latitude);
                                    Clear(Longitude);
                                    Clear(LocationName);

                                    // Extract address information based on document type
                                    case PlanningLine."Type" of
                                        PlanningLine."Type"::Sales:
                                            begin
                                                // Try to get customer address - first check if there's a ship-to address
                                                if SalesHeader.Get(SalesHeader."Document Type"::Order, PlanningLine."Source ID") then begin
                                                    if (SalesHeader."Ship-to Code" <> '') and ShipToAddress.Get(PlanningLine."Account No.", SalesHeader."Ship-to Code") then begin
                                                        LocationName := ShipToAddress.Name;
                                                        Address := ShipToAddress.Address;
                                                        City := ShipToAddress.City;
                                                        PostCode := ShipToAddress."Post Code";
                                                        CountryCode := ShipToAddress."Country/Region Code";
                                                    end else begin
                                                        LocationName := SalesHeader."Ship-to Name";
                                                        Address := SalesHeader."Ship-to Address";
                                                        City := SalesHeader."Ship-to City";
                                                        PostCode := SalesHeader."Ship-to Post Code";
                                                        CountryCode := SalesHeader."Ship-to Country/Region Code";
                                                    end;
                                                end else if Customer.Get(PlanningLine."Account No.") then begin
                                                    // Default to customer address
                                                    LocationName := Customer.Name;
                                                    Address := Customer.Address;
                                                    City := Customer.City;
                                                    PostCode := Customer."Post Code";
                                                    CountryCode := Customer."Country/Region Code";
                                                end;
                                            end;
                                        PlanningLine."Type"::Purchase:
                                            begin
                                                if Vendor.Get(PlanningLine."Account No.") then begin
                                                    LocationName := Vendor.Name;
                                                    Address := Vendor.Address;
                                                    City := Vendor.City;
                                                    PostCode := Vendor."Post Code";
                                                    CountryCode := Vendor."Country/Region Code";
                                                end;
                                            end;
                                        PlanningLine."Type"::Transfer:
                                            begin
                                                if Location.Get(PlanningLine."Location Code") then begin
                                                    LocationName := Location.Name;
                                                    Address := Location.Address;
                                                    City := Location.City;
                                                    PostCode := Location."Post Code";
                                                    CountryCode := Location."Country/Region Code";
                                                end;
                                            end;
                                    end;

                                    // Build the formatted address if we have valid address information
                                    if (Address <> '') or (City <> '') or (PostCode <> '') then begin
                                        LocationCount += 1;

                                        // Format the address for the map URL
                                        if LocationsList <> '' then
                                            LocationsList += '/';

                                        // Format the address with proper URL encoding
                                        LocationsList += EncodeUrl(
                                            FormatAddress(Address, City, PostCode, CountryCode)
                                        );
                                    end;
                                until PlanningLine.Next() = 0;
                            end;

                            if LocationCount > 0 then begin
                                // Use Google Maps directions service for multiple locations
                                if LocationCount > 1 then
                                    MapUrl := 'https://www.google.com/maps/dir/' + LocationsList
                                else
                                    MapUrl := 'https://www.google.com/maps/search/?api=1&query=' + LocationsList;

                                Hyperlink(MapUrl);
                            end else
                                Message('No valid addresses found in the current planning lines.');
                        end;
                    }
                }

                group("Diagnostics")
                {
                    Caption = 'Diagnostics';
                    Image = TestDatabase;
                    Visible = true;

                    action("Test Document Addition")
                    {
                        ApplicationArea = All;
                        Caption = 'Test Document Addition';
                        Image = TestReport;
                        ToolTip = 'Tests the document addition functionality with a diagnostic message.';

                        trigger OnAction()
                        begin
                            TestDocumentAddition();
                        end;
                    }

                    action("Check Planning Completeness")
                    {
                        ApplicationArea = All;
                        Caption = 'Check Planning Completeness';
                        Image = CheckList;
                        ToolTip = 'Checks if all lines have assigned days and proper planning.';

                        trigger OnAction()
                        begin
                            CheckPlanningCompleteness();
                        end;
                    }

                    action("Fix Planning Lines")
                    {
                        ApplicationArea = All;
                        Caption = 'Fix Planning Lines';
                        Image = Repair;
                        ToolTip = 'Attempts to fix common issues with planning lines.';

                        trigger OnAction()
                        begin
                            FixPlanningLines();
                        end;
                    }

                    action("Test Document Add")
                    {
                        ApplicationArea = All;
                        Caption = 'Test Add Document';
                        Image = Document;
                        ToolTip = 'Directly tests adding a document without using the selection page.';

                        trigger OnAction()
                        var
                            SalesHeader: Record "Sales Header";
                            DocBuffer: Record "Planning Document Buffer" temporary;
                            SalesLine: Record "Sales Line";
                            PlanningLineMgt: Codeunit "Planning Lines Management";
                        begin
                            // Make sure we have a valid tour number
                            if Rec."Logistic Tour No." = '' then begin
                                Error('Tour number is missing. Please save the document first.');
                                exit;
                            end;

                            // Find a sales order to test with
                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                            SalesHeader.SetFilter(Status, '%1|%2', SalesHeader.Status::Open, SalesHeader.Status::Released);

                            if not SalesHeader.FindFirst() then begin
                                Message('No sales orders found for testing');
                                exit;
                            end;

                            // Create test buffer record
                            DocBuffer.Init();
                            DocBuffer."Line No." := 1;
                            DocBuffer."Document Type" := DocBuffer."Document Type"::"Sales Order";
                            DocBuffer."Document No." := SalesHeader."No.";
                            DocBuffer."Account Type" := DocBuffer."Account Type"::Customer;
                            DocBuffer."Account No." := SalesHeader."Sell-to Customer No.";
                            DocBuffer."Account Name" := SalesHeader."Sell-to Customer Name";
                            DocBuffer."Location Code" := SalesHeader."Location Code";
                            DocBuffer."Document Date" := SalesHeader."Document Date";
                            DocBuffer."Delivery Date" := SalesLine."Planned Shipment Date";
                            DocBuffer.Priority := SalesHeader.Priority;
                            DocBuffer.Selected := true;

                            // Explicitly set the Tour No. in the buffer
                            DocBuffer."Tour No." := Rec."Logistic Tour No.";

                            DocBuffer.Insert();

                            // Call the PlanningLineMgt codeunit directly
                            if Rec.Statut = Rec.Statut::Plannified then begin
                                ClearLastError();
                                Message('Attempting to add sales order %1 to tour %2...',
                                    SalesHeader."No.", Rec."Logistic Tour No.");

                                PlanningLineMgt.AddDocumentToTour(Rec, DocBuffer);
                                Message('Document was successfully added.');
                                CurrPage.Update(false);
                            end else
                                Message('Tour must be in Plannified status to add documents.');
                        end;
                    }
                }
            }
            group("Location Controls")
            {
                Caption = 'Location Controls';
                Image = Location;

                action("Set Default Locations")
                {
                    ApplicationArea = All;
                    Caption = 'Set Default Locations';
                    Image = Default;
                    ToolTip = 'Sets the start and end locations to the default values from company setup.';

                    trigger OnAction()
                    var
                        SetupRec: Record "Trip Setup";
                        ConfirmManagement: Codeunit "Confirm Management";
                    begin
                        if ConfirmManagement.GetResponseOrDefault('Do you want to set the start and end locations to the default values from company setup?', true) then begin
                            SetupRec.Get();

                            if SetupRec."Default Start Location" <> '' then
                                Rec.Validate("Start Location", SetupRec."Default Start Location")
                            else if SetupRec."Location Code" <> '' then
                                Rec.Validate("Start Location", SetupRec."Location Code");

                            if SetupRec."Default End Location" <> '' then
                                Rec.Validate("End Location", SetupRec."Default End Location")
                            else if SetupRec."Location Code" <> '' then
                                Rec.Validate("End Location", SetupRec."Location Code");

                            if setupRec."Default Start Location" <> '' then
                                rec.Validate("Location Code", SetupRec."Location Code")

                            else if setupRec."Location Code" <> '' then
                                rec.Validate("Location Code", SetupRec."Location Code");

                            Rec.Modify(true);
                        end;
                    end;
                }

                action("Clear Locations")
                {
                    ApplicationArea = All;
                    Caption = 'Clear Locations';
                    Image = ClearFilter;
                    ToolTip = 'Clears the start and end locations.';

                    trigger OnAction()
                    var
                        ConfirmManagement: Codeunit "Confirm Management";
                    begin
                        if ConfirmManagement.GetResponseOrDefault('Do you want to clear the start and end locations?', true) then begin
                            Rec.Validate("Start Location", '');
                            Rec.Validate("End Location", '');
                            Rec.Modify(true);
                        end;
                    end;
                }

                action("Swap Locations")
                {
                    ApplicationArea = All;
                    Caption = 'Swap Start/End Locations';
                    Image = Rotate;
                    ToolTip = 'Swaps the start and end locations.';

                    trigger OnAction()
                    var
                        TempLocation: Code[20];
                        ConfirmManagement: Codeunit "Confirm Management";
                    begin
                        if ConfirmManagement.GetResponseOrDefault('Do you want to swap the start and end locations?', true) then begin
                            TempLocation := Rec."Start Location";
                            Rec.Validate("Start Location", Rec."End Location");
                            Rec.Validate("End Location", TempLocation);
                            Rec.Modify(true);
                        end;
                    end;
                }
            }
        }

        area(Navigation)
        {
            action("Vehcile Charging Preparation")
            {
                ApplicationArea = All;
                Caption = 'Vehcile Charging Preparation';
                Image = SuggestWorkMachCost;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    VehicleLoadingHeader: Record "Vehicle Loading Header";
                    PlanningLine: Record "Planning Lines";
                    VehicleLoadingCard: Page "Vehicle Loading Card";
                    VehicleStopLine: Record "vehicle Stop Line";
                    StopNo: Integer;
                    NoSeriesMgt: Codeunit "No. Series";
                    ErrorMsg: Text;
                begin
                    // Validate required fields before creating the preparation
                    ErrorMsg := '';

                    if Rec."Logistic Tour No." = '' then
                        ErrorMsg += 'Tour No. must be specified.\';

                    if Rec."Start Date" = 0D then
                        ErrorMsg += 'Start Date must be specified.\';

                    if Rec."Véhicule No." = '' then
                        ErrorMsg += 'Vehicle No. must be specified.\';

                    if Rec."Driver No." = '' then
                        ErrorMsg += 'Driver No. must be specified.\';

                    // if Rec."Delivery Area" = '' then
                    //     ErrorMsg += 'Delivery Area must be specified.\';

                    // Check if there are any planning lines
                    PlanningLine.Reset();
                    PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                    if PlanningLine.IsEmpty() then
                        ErrorMsg += 'At least one planning line must be created.\';

                    if ErrorMsg <> '' then begin
                        Error(ErrorMsg);
                        exit;
                    end;

                    if not Confirm('Do you want to create a vehicle loading preparation for this tour?') then
                        exit;

                    // Set status to Loading when loading phase starts
                    Rec.Statut := Rec.Statut::Loading;
                    Rec.Modify(true);

                    // Check if a vehicle loading sheet already exists for this tour
                    VehicleLoadingHeader.Reset();
                    VehicleLoadingHeader.SetRange("Tour No.", Rec."Logistic Tour No.");
                    if VehicleLoadingHeader.FindFirst() then begin
                        if Confirm('A vehicle loading preparation already exists for this tour. Do you want to view it?') then begin
                            VehicleLoadingCard.SetRecord(VehicleLoadingHeader);
                            VehicleLoadingCard.Run();
                        end;
                        exit;
                    end;

                    // Create new vehicle loading header
                    VehicleLoadingHeader.Init();
                    VehicleLoadingHeader."No." := NoSeriesMgt.GetNextNo('VLOAD', Today);
                    VehicleLoadingHeader."Loading Date" := Today;
                    VehicleLoadingHeader."Tour No." := Rec."Logistic Tour No.";
                    VehicleLoadingHeader."Vehicle No." := Rec."Véhicule No.";
                    VehicleLoadingHeader."Driver No." := Rec."Driver No.";
                    VehicleLoadingHeader."Loading Location" := Rec."Véhicule No."; // Assuming vehicle location is the loading location
                    VehicleLoadingHeader."Departure Time" := Rec."Working Hours Start";
                    VehicleLoadingHeader."Warehouse Location" := rec."Location Code";
                    VehicleLoadingHeader."Status" := VehicleLoadingHeader."Status"::Planned;

                    // Calculate tour metrics
                    VehicleLoadingHeader."Total Weight (kg)" := 0;
                    VehicleLoadingHeader."Total Volume (m³)" := 0;
                    VehicleLoadingHeader."Number of Deliveries" := 0;

                    // Insert the header record
                    if VehicleLoadingHeader.Insert(true) then begin
                        // Create stop lines from planning lines
                        StopNo := 0;
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                        PlanningLine.SetCurrentKey("Assigned Day", "Time Slot Start");

                        if PlanningLine.FindSet() then
                            repeat
                                StopNo += 1;
                                VehicleStopLine.Init();
                                VehicleStopLine."Fiche No." := VehicleLoadingHeader."No.";
                                VehicleStopLine."Stop No." := StopNo;
                                VehicleStopLine.type := PlanningLine."Type";
                                VehicleStopLine."Customer No." := PlanningLine."Account No.";
                                VehicleStopLine.item := PlanningLine."Item No.";
                                VehicleStopLine."Delivery Address" := PlanningLine."ship-to Address";
                                VehicleStopLine."Estimated Arrival Time" := PlanningLine."Time Slot Start";
                                VehicleStopLine."Estimated Departure Time" := PlanningLine."Time Slot End";
                                VehicleStopLine."Quantity to Deliver" := PlanningLine.Quantity;
                                VehicleStopLine.Description := PlanningLine.Description;
                                // VehicleStopLine."Remarks" := PlanningLine.re;
                                VehicleStopLine."Gross weight" := PlanningLine."Gross Weight";
                                VehicleStopLine."Unit volume" := PlanningLine."Unit Volume";
                                VehicleStopLine."Unit of Measure Code" := PlanningLine."Unit of Measure Code";

                                VehicleStopLine.Insert(true);

                                // Update header totals
                                VehicleLoadingHeader."Number of Deliveries" += 1;
                                VehicleLoadingHeader."Total Weight (kg)" += PlanningLine."Gross Weight";
                                // Assuming volume calculation if available
                                VehicleLoadingHeader."Total Volume (m³)" += PlanningLine."Quantity" * PlanningLine."Unit Volume";
                            until PlanningLine.Next() = 0;

                        // Update the header with the calculated totals
                        VehicleLoadingHeader.Modify(true);

                        // Open the new vehicle loading card
                        Message('Vehicle loading preparation %1 has been created.', VehicleLoadingHeader."No.");
                        VehicleLoadingCard.SetRecord(VehicleLoadingHeader);
                        VehicleLoadingCard.Run();
                    end else
                        Error('Failed to create vehicle loading preparation.');
                end;
            }
            action("Go to Execution")
            {
                ApplicationArea = All;
                Caption = 'Go to Execution';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TMSProcessFlow: Codeunit "Tour Execution Management";
                begin
                    TMSProcessFlow.InitializeTourExecution(Rec."Logistic Tour No.");
                end;
            }

            action("Transfer Routes")
            {
                ApplicationArea = Location;
                Caption = 'Transfer Routes';
                Image = Setup;
                RunObject = Page "Transfer Routes";
                ToolTip = 'View the list of transfer routes that are set up to transfer items from one location to another.';
            }

            // action("Vehicle Loading Management")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Vehicle Loading Management';
            //     Image = MachineCenterLoad;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     RunObject = Page "Vehicle Loading Management";
            //     ToolTip = 'View and manage both loading preparation and vehicle charging operations.';

            // }
        }
    }

    // Placeholder pour le style du statut
    var
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        CalculateTotalQuantity();
    end;

    trigger OnOpenPage()
    begin
        SetStatusStyle();
    end;

    procedure SetStatusStyle()
    begin
        case Rec.Statut of
            Rec.Statut::Plannified:
                StatusStyleExpr := 'Favorable';
            Rec.Statut::Loading:
                StatusStyleExpr := 'Attention';
            Rec.Statut::Stopped:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;

    procedure CalculateTotalQuantity()
    var
        PlanningLine: Record "Planning Lines";
    begin
        if Rec."Logistic Tour No." = '' then
            exit;

        // Calculate flow fields
        Rec.CalcFields("Total Quantity", "No. of Planning Lines");
    end;

    // Placeholder procedures for the new actions

    local procedure OpenSourceDocumentSelection()
    var
        SourceDocumentPage: Page "Source Document Selection";
    begin
        // Basic validation
        if Rec."Logistic Tour No." = '' then begin
            if not Confirm('Tour number is missing. Would you like to save the tour first?') then
                exit;

            // Attempt to save the record
            if Rec.Insert(true) then
                Message('Tour created with number: %1', Rec."Logistic Tour No.")
            else if Rec.Modify(true) then
                Message('Tour saved with number: %1', Rec."Logistic Tour No.")
            else begin
                Error('Could not save the tour. Please try again.');
                exit;
            end;
        end;

        // Ensure we have a valid tour number now
        if Rec."Logistic Tour No." = '' then begin
            Error('Failed to get a valid tour number. Please save the tour manually and try again.');
            exit;
        end;

        // Set up the page with current record - pass the full record
        Clear(SourceDocumentPage);
        Message('Opening Source Document Selection with Tour No: %1', Rec."Logistic Tour No.");
        SourceDocumentPage.SetTourHeader(Rec);

        // Run the page
        SourceDocumentPage.RunModal();

        // Check result
        if SourceDocumentPage.IsActionOK() then begin
            // Refresh page
            CurrPage.Update(true);
            Message('Documents have been added to the tour %1.', Rec."Logistic Tour No.");
        end;
    end;

    local procedure GetSalesOrdersForPlanning()
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderPage: Page "Sales Order List";
        salesline: Record "Sales Line";
        PlanningLineMgt: Codeunit "Planning Lines Management";
        DocBuffer: Record "Planning Document Buffer" temporary;
        SelectedCount: Integer;
        ErrorCount: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        if Rec."Logistic Tour No." = '' then begin
            Error('Please save the tour document first before adding documents.');
        end;

        // Configure filter for open/released sales orders
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter(Status, '%1|%2', SalesHeader.Status::Open, SalesHeader.Status::Released);

        if Rec."Start Date" <> 0D then
            salesline.SetFilter("planned Shipment Date", '>=%1', Rec."Start Date");

        if Rec."End Date" <> 0D then
            salesline.SetFilter("planned Shipment Date", '<=%1', Rec."End Date");

        // Configure selection page
        SalesHeaderPage.SetTableView(SalesHeader);
        SalesHeaderPage.LookupMode(true);

        // Show page and process selection
        if SalesHeaderPage.RunModal() = Action::LookupOK then begin
            SalesHeaderPage.SetSelectionFilter(SalesHeader);
            if not SalesHeader.FindSet() then begin
                Message('No sales orders were selected.');
                exit;
            end;

            repeat
                // Prepare document buffer for each selected sales order
                DocBuffer.Init();
                DocBuffer."Line No." := SelectedCount + 1;
                DocBuffer."Document Type" := DocBuffer."Document Type"::"Sales Order";
                DocBuffer."Document No." := SalesHeader."No.";
                DocBuffer."Account Type" := DocBuffer."Account Type"::Customer;
                DocBuffer."Account No." := salesline."Sell-to Customer No.";
                DocBuffer."Account Name" := SalesHeader."Sell-to Customer Name";
                DocBuffer."Location Code" := salesline."Location Code";
                DocBuffer."Document Date" := SalesHeader."Document Date";
                DocBuffer."Delivery Date" := SalesLine."Planned Shipment Date";
                DocBuffer.Priority := SalesHeader.Priority;
                DocBuffer.Selected := true;

                // Explicitly set the Tour No. in the buffer
                DocBuffer."Tour No." := Rec."Logistic Tour No.";

                DocBuffer.Insert();

                // Add the sales order to tour using the management codeunit
                if Rec.Statut = Rec.Statut::Plannified then begin
                    ClearLastError();
                    if not Codeunit.Run(Codeunit::"Planning Lines Management", DocBuffer) then begin
                        PlanningDiag.LogPlanningLineIssues(Rec."Logistic Tour No.", '',
                            StrSubstNo('Error adding Sales Order %1: %2', SalesHeader."No.", GetLastErrorText));
                        ErrorCount += 1;
                    end else
                        SelectedCount += 1;
                end else begin
                    Message('Cannot add documents to a %1 tour.', Rec.Statut);
                    exit;
                end;
            until SalesHeader.Next() = 0;

            if SelectedCount > 0 then begin
                Message('%1 sales order(s) added to the tour.', SelectedCount);
                if ErrorCount > 0 then
                    Message('%1 sales order(s) could not be added due to errors. See log for details.', ErrorCount);
                CurrPage.Update(false);
            end;
        end;
    end;

    local procedure GetPurchaseOrdersForPlanning()
    var
        PurchHeader: Record "Purchase Header";
        PurchHeaderPage: Page "Purchase Order List";
        PlanningLineMgt: Codeunit "Planning Lines Management";
        PurchLine: Record "Purchase Line";
        DocBuffer: Record "Planning Document Buffer" temporary;
        SelectedCount: Integer;
    begin
        // Configure filter for open/released purchase orders
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetFilter(Status, '%1|%2', PurchHeader.Status::Open, PurchHeader.Status::Released);

        if Rec."Start Date" <> 0D then
            PurchLine.SetFilter("Expected Receipt Date", '>=%1', Rec."Start Date");

        if Rec."End Date" <> 0D then
            PurchLine.SetFilter("Expected Receipt Date", '<=%1', Rec."End Date");

        // Configure selection page
        PurchHeaderPage.SetTableView(PurchHeader);
        PurchHeaderPage.LookupMode(true);

        // Show page and process selection
        if PurchHeaderPage.RunModal() = Action::LookupOK then begin
            PurchHeaderPage.SetSelectionFilter(PurchHeader);
            if PurchHeader.FindSet() then
                repeat
                    // Prepare document buffer for each selected purchase order
                    DocBuffer.Init();
                    DocBuffer."Line No." := SelectedCount + 1;
                    DocBuffer."Document Type" := DocBuffer."Document Type"::"Purchase Order";
                    DocBuffer."Document No." := PurchHeader."No.";
                    DocBuffer."Account Type" := DocBuffer."Account Type"::Vendor;
                    DocBuffer."Account No." := PurchHeader."Buy-from Vendor No.";
                    DocBuffer."Account Name" := PurchHeader."Buy-from Vendor Name";
                    DocBuffer."Location Code" := PurchHeader."Location Code";
                    DocBuffer."Document Date" := PurchHeader."Document Date";
                    DocBuffer."Delivery Date" := PurchLine."Expected Receipt Date";
                    DocBuffer.Priority := DocBuffer.Priority::Normal;
                    DocBuffer.Selected := true;

                    // Explicitly set the Tour No. in the buffer
                    DocBuffer."Tour No." := Rec."Logistic Tour No.";

                    DocBuffer.Insert();

                    // Add the purchase order to tour using the management codeunit
                    PlanningLineMgt.AddDocumentToTour(Rec, DocBuffer);
                    SelectedCount += 1;
                until PurchHeader.Next() = 0;

            if SelectedCount > 0 then begin
                Message('%1 purchase order(s) added to the tour.', SelectedCount);
                CurrPage.Update(false);
            end;
        end;
    end;

    local procedure GetTransferOrdersForPlanning()
    var
        TransferHeader: Record "Transfer Header";
        TransferHeaderPage: Page "Transfer Orders";
        PlanningLineMgt: Codeunit "Planning Lines Management";
        DocBuffer: Record "Planning Document Buffer" temporary;
        SelectedCount: Integer;
    begin
        // Configure filter for open/released transfer orders
        TransferHeader.SetFilter(Status, '%1|%2', TransferHeader.Status::Open, TransferHeader.Status::Released);

        if Rec."Start Date" <> 0D then
            TransferHeader.SetFilter("Receipt Date", '>=%1', Rec."Start Date");

        if Rec."End Date" <> 0D then
            TransferHeader.SetFilter("Receipt Date", '<=%1', Rec."End Date");

        // Configure selection page
        TransferHeaderPage.SetTableView(TransferHeader);
        TransferHeaderPage.LookupMode(true);

        // Show page and process selection
        if TransferHeaderPage.RunModal() = Action::LookupOK then begin
            TransferHeaderPage.SetSelectionFilter(TransferHeader);
            if TransferHeader.FindSet() then
                repeat
                    // Prepare document buffer for each selected transfer order
                    DocBuffer.Init();
                    DocBuffer."Line No." := SelectedCount + 1;
                    DocBuffer."Document Type" := DocBuffer."Document Type"::"Transfer Order";
                    DocBuffer."Document No." := TransferHeader."No.";
                    DocBuffer."Account Type" := DocBuffer."Account Type"::Location;
                    DocBuffer."Account No." := TransferHeader."Transfer-to Code";
                    DocBuffer."Account Name" := TransferHeader."Transfer-to Name";
                    DocBuffer."Location Code" := TransferHeader."Transfer-to Code";
                    DocBuffer."Document Date" := WorkDate(); // Transfer headers don't have document date
                    DocBuffer."Delivery Date" := TransferHeader."Receipt Date";
                    DocBuffer.Priority := DocBuffer.Priority::Normal;
                    DocBuffer.Selected := true;

                    // Explicitly set the Tour No. in the buffer
                    DocBuffer."Tour No." := Rec."Logistic Tour No.";

                    DocBuffer.Insert();

                    // Add the transfer order to tour using the management codeunit
                    PlanningLineMgt.AddDocumentToTour(Rec, DocBuffer);
                    SelectedCount += 1;
                until TransferHeader.Next() = 0;

            if SelectedCount > 0 then begin
                Message('%1 transfer order(s) added to the tour.', SelectedCount);
                CurrPage.Update(false);
            end;
        end;
    end;

    local procedure AutoAssignDays()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        if not Confirm('Lancer l''optimisation automatique des jours de planification?', true) then
            exit;

        PlanningLineMgt.AutoAssignDays(Rec);

        // Update the page to show changes
        CurrPage.Update(false);
    end;

    local procedure GroupByProximity()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        PlanningLineMgt.GroupByProximity(Rec);
        Message('Planning lines have been grouped by proximity.');
    end;

    local procedure GroupByCustomer()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        PlanningLineMgt.GroupByCustomer(Rec);
        Message('Planning lines have been grouped by customer.');
    end;

    local procedure GroupByActivityType()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        PlanningLineMgt.GroupByActivityType(Rec);
        Message('Planning lines have been grouped by activity type.');
    end;

    local procedure BalanceWorkload()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        PlanningLineMgt.BalanceWorkload(Rec);
        Message('Workload has been balanced across planning days.');
    end;

    local procedure OptimizeRoutes()
    var
        PlanningLineMgt: Codeunit "Planning Lines Management";
    begin
        PlanningLineMgt.OptimizeRoutes(Rec);
        Message('Routes have been optimized for each day.');
    end;

    local procedure ShowCalendarView()
    begin
        Message('Calendar view will open here.');
        // To be implemented
    end;

    local procedure ShowMapView()
    begin
        Message('Map view will open here.');
        // To be implemented
    end;

    local procedure ShowRouteOverview()
    begin
        Message('Route overview will open here.');
        // To be implemented
    end;

    local procedure TestDocumentAddition()
    var
        PlanningDiagnostics: Codeunit "Planning Diagnostics";
    begin
        if Rec."Logistic Tour No." = '' then begin
            Message('Please save the tour document first before testing');
            exit;
        end;

        PlanningDiagnostics.TestDocumentAddition(Rec);
        CurrPage.Update(false);
    end;

    local procedure CheckPlanningCompleteness()
    var
        PlanningLine: Record "Planning Lines";
        NoAssignedDay: Integer;
        NoActivity: Integer;
        NoGrouped: Integer;
        TotalLines: Integer;
    begin
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        TotalLines := PlanningLine.Count;

        if TotalLines = 0 then begin
            Message('No planning lines found for this tour.');
            exit;
        end;

        // Check for missing assigned days
        PlanningLine.SetRange("Assigned Day", 0D);
        NoAssignedDay := PlanningLine.Count;
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");

        // Count lines missing activity type - we'll use a counter variable instead of a filter
        if PlanningLine.FindSet() then
            repeat
                // Check if Activity Type is not set (should be 0 which is Delivery in this case)
                // But we may need to adjust this check based on business logic
                if (PlanningLine."Activity Type" = 0) and (PlanningLine.Type <> PlanningLine.Type::Sales) then
                    NoActivity += 1;
            until PlanningLine.Next() = 0;

        // Check for ungrouped lines
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        PlanningLine.SetRange("Group Type", PlanningLine."Group Type"::None);
        NoGrouped := PlanningLine.Count;

        // Report results
        Message('Planning completeness check:\n' +
                '%1 total planning lines\n' +
                '%2 lines missing assigned day\n' +
                '%3 lines that may have incorrect activity type\n' +
                '%4 lines not grouped',
                TotalLines, NoAssignedDay, NoActivity, NoGrouped);
    end;

    local procedure FixPlanningLines()
    var
        PlanningLine: Record "Planning Lines";
        PlanningLineMgt: Codeunit "Planning Lines Management";
        LinesUpdated: Integer;
    begin
        if not Confirm('This will attempt to fix common issues with planning lines. Continue?') then
            exit;

        // Fix lines with missing assigned days
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        PlanningLine.SetRange("Assigned Day", 0D);

        if PlanningLine.FindSet() then
            repeat
                // Assign to start date if planned date is not in range
                if (PlanningLine." Delivery Date" >= Rec."Start Date") and
                   (PlanningLine." Delivery Date" <= Rec."End Date") then
                    PlanningLine."Assigned Day" := PlanningLine." Delivery Date"
                else
                    PlanningLine."Assigned Day" := Rec."Start Date";

                PlanningLine.Modify();
                LinesUpdated += 1;
            until PlanningLine.Next() = 0;

        // Balance workload after fixing
        if LinesUpdated > 0 then
            PlanningLineMgt.BalanceWorkload(Rec);

        Message('%1 planning lines were fixed and workload was rebalanced.', LinesUpdated);
        CurrPage.Update(false);
    end;

    local procedure IsNonWorkingDay(CheckDate: Date): Boolean
    var
        NonWorkingDays: Text;
        DateTokens: List of [Text];
        DateToken: Text;
        NonWorkingDate: Date;
    begin
        NonWorkingDays := Rec."Non-Working Days";
        if NonWorkingDays = '' then
            exit(false);

        DateTokens := NonWorkingDays.Split(',');
        foreach DateToken in DateTokens do begin
            if Evaluate(NonWorkingDate, DateToken.Trim()) then
                if NonWorkingDate = CheckDate then
                    exit(true);
        end;

        exit(false);
    end;

    // action(LoadPlanningLines)
    // {
    //     ApplicationArea = All;
    //     Caption = 'Charger les lignes de planification';
    //     Image = Process;
    //     Promoted = true;
    //     PromotedCategory = Process;
    //     PromotedIsBig = true;

    //     trigger OnAction()
    //     var
    //         PlanningLoader: Codeunit "Planning Line Loader";
    //     begin
    //         PlanningLoader.LoadLines(Rec."Logistic Tour No.", Rec."Date de Tournée");
    //         CurrPage.Update(false);
    //     end;
    // }
    // group("Charger les lignes")
    // {
    //     Caption = 'Charger les lignes';
    //     Image = GetLines;

    //     action(LoadAllLines)
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Charger toutes les lignes';
    //         Image = GetLines;

    //         trigger OnAction()
    //         var
    //             PlanningLoader: Codeunit "Planning Line Loader";
    //         begin
    //             PlanningLoader.LoadLines(Rec."Logistic Tour No.", Rec."Date de Tournée");
    //             CurrPage.Update(false);
    //         end;
    //     }

    //     action(LoadSalesLines)
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Charger les lignes de vente';
    //         Image = Sales;

    //         trigger OnAction()
    //         var
    //             PlanningLoader: Codeunit "Planning Line Loader";
    //         begin
    //             PlanningLoader.LoadSalesLines(Rec."Logistic Tour No.", Rec."Date de Tournée");
    //             CurrPage.Update(false);
    //         end;
    //     }

    //     action(LoadPurchaseLines)
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Charger les lignes d''achat';
    //         Image = Purchase;

    //         trigger OnAction()
    //         var
    //             PlanningLoader: Codeunit "Planning Line Loader";
    //         begin
    //             PlanningLoader.LoadPurchaseLines(Rec."Logistic Tour No.", Rec."Date de Tournée");
    //             CurrPage.Update(false);
    //         end;
    //     }

    //     action(LoadTransferLines)
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Charger les lignes de transfert';
    //         Image = TransferOrder;

    //         trigger OnAction()
    //         var
    //             PlanningLoader: Codeunit "Planning Line Loader";
    //         begin
    //             PlanningLoader.LoadTransferLines(Rec."Logistic Tour No.", Rec."Date de Tournée");
    //             CurrPage.Update(false);
    //         end;
    //     }
    // }


    // group("Fetch Planning Lines")
    // {
    //     action("Get Sales Lines")
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Get Sales Lines';
    //         Image = Import;

    //         trigger OnAction()
    //         var
    //             PlanningLineFetcher: Codeunit "Planning Line Fetcher";
    //         begin
    //             PlanningLineFetcher.FetchSalesLines(Rec."No.");
    //             CurrPage.Update(); // Pour rafraîchir le subform
    //         end;
    //     }

    //     action("Get Purchase Lines")
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Get Purchase Lines';
    //         Image = Import;

    //         trigger OnAction()
    //         var
    //             PlanningLineFetcher: Codeunit "Planning Line Fetcher";
    //         begin
    //             PlanningLineFetcher.FetchPurchaseLines(Rec."No.");
    //             CurrPage.Update(); // Pour rafraîchir le subform
    //         end;
    //     }

    //     action("Get Transfer Lines")
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Get Transfer Lines';
    //         Image = Import;

    //         trigger OnAction()
    //         var
    //             PlanningLineFetcher: Codeunit "Planning Line Fetcher";
    //         begin
    //             PlanningLineFetcher.FetchTransferLines(Rec."No.");
    //             CurrPage.Update(); // Pour rafraîchir le subform
    //         end;
    //     }

    //     area(Navigation)
    // {
    //     action("Create Vehicle Loading")
    //     {
    //         Caption = 'Create Vehicle Loading';
    //         ApplicationArea = All;
    //         Image = Add;

    //         trigger OnAction()
    //         var
    //             VehicleLoadingRec: Record "Vehicle Loading";
    //             VehicleLoadingPage: Page "Vehicle Loading Card";
    //         begin
    //             VehicleLoadingRec.Init();
    //             VehicleLoadingRec."Loading Date" := Today;
    //             VehicleLoadingRec."Vehicle No." := Rec."Véhicule No.";
    //             VehicleLoadingRec."Driver Name" := Rec."Driver No.";
    //             VehicleLoadingRec.Insert(true); // true = run trigger

    //             // Ouvrir la page carte avec l'enregistrement nouvellement créé
    //             VehicleLoadingPage.SetRecord(VehicleLoadingRec);
    //             VehicleLoadingPage.Run();
    //         end;
    //     }
    // }

    // Add a procedure to update status to InProgress when charging phase starts
    procedure SetStatusInProgressIfChargingStarted(TourNo: Code[20])
    var
        PlanHeader: Record "Planification Header";
    begin
        if PlanHeader.Get(TourNo) then begin
            PlanHeader.Statut := PlanHeader.Statut::loading;
            PlanHeader.Modify(true);
        end;
    end;

    local procedure EncodeUrl(TextToEncode: Text): Text
    var
        TempText: Text;
    begin
        TempText := TextToEncode;
        TempText := DelChr(TempText, '=', ' '); // Remove spaces
        TempText := ReplaceStr(TempText, ' ', '+');
        exit(TempText);
    end;

    local procedure ReplaceStr(Source: Text; OldValue: Text; NewValue: Text): Text
    var
        Pos: Integer;
    begin
        while true do begin
            Pos := StrPos(Source, OldValue);
            if Pos = 0 then
                exit(Source);
            Source := CopyStr(Source, 1, Pos - 1) + NewValue + CopyStr(Source, Pos + StrLen(OldValue));
        end;
    end;

    local procedure FormatAddress(StreetAddress: Text; City: Text; PostCode: Text; CountryCode: Text): Text
    var
        FormattedAddress: Text;
    begin
        FormattedAddress := '';

        if StreetAddress <> '' then
            FormattedAddress += StreetAddress;

        if City <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ', ';
            FormattedAddress += City;
        end;

        if PostCode <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ' ';
            FormattedAddress += PostCode;
        end;

        if CountryCode <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ', ';
            FormattedAddress += CountryCode;
        end;

        exit(FormattedAddress);
    end;

    // Add a procedure to update status to Closed when execution is completed
    procedure SetStatusCompletedIfExecutionCompleted(TourNo: Code[20])
    var
        PlanHeader: Record "Planification Header";
    begin
        if PlanHeader.Get(TourNo) then begin
            PlanHeader.Statut := PlanHeader.Statut::Completed;
            PlanHeader.Modify(true);
        end;
    end;

}