page 77150 "Tal Online Map Setup"
{
    ApplicationArea = All;
    Caption = 'Online Map Parameter Setup';
    PageType = List;
    SourceTable = "Online Map Parameters";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the map service.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the map service.';
                }
                field("Map Service"; Rec."Map Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL for the map service.';
                }
                field("Directions Service"; Rec."Directions Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL for the directions service.';
                }
                field("Directions from Location Service"; Rec."Directions from Location Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL for the directions from location service.';
                }
                field("URL Encoding"; Rec."URL Encoding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if URL encoding is needed.';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for the map service.';
                }
                field("Is Default"; Rec."Is Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is the default map service.';
                }
            }
        }
        area(factboxes)
        {
            part(Details; "Online Map Substitution Part")
            {
                ApplicationArea = All;
                Caption = 'Details';
                SubPageLink = "Parameter ID" = const(0);
            }
            part(Attachments; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(77150), "No." = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create a new map service configuration.';

                trigger OnAction()
                begin
                    // Create a new record
                end;
            }

            action("Edit List")
            {
                ApplicationArea = All;
                Caption = 'Edit List';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Edit the list of map services.';

                trigger OnAction()
                begin
                    // Edit list
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete the selected map service.';

                trigger OnAction()
                begin
                    // Delete record
                end;
            }

            action("Insert Default")
            {
                ApplicationArea = All;
                Caption = 'Insert Default';
                Image = Default;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Insert default map service configurations.';

                trigger OnAction()
                begin
                    InsertDefaultMapServices();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MapSubstitution: Record "Online Map Substitution";
    begin
        // Initialize standard parameters if they don't exist yet
        MapSubstitution.InitializeStandardParameters();
    end;

    local procedure InsertDefaultMapServices()
    var
        MapParam: Record "Online Map Parameters";
    begin
        // Insert Bing Maps as default
        if not MapParam.Get('BING') then begin
            MapParam.Init();
            MapParam.Code := 'BING';
            MapParam.Name := 'Bing Maps';
            MapParam."Map Service" := 'https://bing.com/maps/default.aspx?rtp=~pos.{0}_{1}_{2}';
            MapParam."Directions Service" := 'https://bing.com/maps/default.aspx?rtp=adr.{0}~adr.{1}';
            MapParam."Directions from Location Service" := 'https://bing.com/maps/default.aspx?rtp=pos.{0}_{1}~pos.{2}_{3}';
            MapParam."URL Encoding" := true;
            MapParam."Is Default" := true;
            MapParam.Insert();
        end;

        // Insert Google Maps
        if not MapParam.Get('GOOGLE') then begin
            MapParam.Init();
            MapParam.Code := 'GOOGLE';
            MapParam.Name := 'Google Maps';
            MapParam."Map Service" := 'https://maps.googleapis.com/maps/api/staticmap?center={0},{1}&zoom=14&size=400x400&markers=color:red|{0},{1}';
            MapParam."Directions Service" := 'https://www.google.com/maps/dir/?api=1&origin={0}&destination={1}&travelmode=driving';
            MapParam."Directions from Location Service" := 'https://www.google.com/maps/dir/?api=1&origin={0},{1}&destination={2},{3}&travelmode=driving';
            MapParam."URL Encoding" := true;
            MapParam.Insert();
        end;
    end;
}