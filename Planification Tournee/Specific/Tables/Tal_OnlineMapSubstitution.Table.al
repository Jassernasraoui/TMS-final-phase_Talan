table 77151 "Online Map Substitution"
{
    Caption = 'Online Map Substitution Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Parameter ID"; Integer)
        {
            Caption = 'Parameter ID';
            DataClassification = CustomerContent;
        }
        field(2; "Parameter Name"; Text[50])
        {
            Caption = 'Parameter Name';
            DataClassification = CustomerContent;
        }
        field(3; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Parameter ID")
        {
            Clustered = true;
        }
    }

    // Cette procédure va initialiser les paramètres standard
    procedure InitializeStandardParameters()
    var
        Param: Record "Online Map Substitution";
    begin
        if not Param.IsEmpty then
            exit;

        InsertParameter(1, 'Street (Address1)', 'Street or Address line 1');
        InsertParameter(2, 'City', 'City');
        InsertParameter(3, 'State (County)', 'State, County, or Province');
        InsertParameter(4, 'Post Code/ZIP Code', 'Postal Code or ZIP Code');
        InsertParameter(5, 'Country/Region Code', 'Country or Region Code');
        InsertParameter(6, 'Country/Region Name', 'Full Country or Region Name');
        InsertParameter(7, 'Culture Information', 'Culture Information, e.g., en-us');
        InsertParameter(8, 'Distance in (Miles/Kilometers)', 'Distance Unit');
        InsertParameter(9, 'Route (Quickest/Shortest)', 'Route Type');
        InsertParameter(10, 'GPS Latitude', 'GPS Latitude Coordinate');
        InsertParameter(11, 'GPS Longitude', 'GPS Longitude Coordinate');
    end;

    local procedure InsertParameter(ID: Integer; Name: Text[50]; Desc: Text[100])
    var
        Param: Record "Online Map Substitution";
    begin
        Param.Init();
        Param."Parameter ID" := ID;
        Param."Parameter Name" := Name;
        Param.Description := Desc;
        Param.Insert();
    end;
}