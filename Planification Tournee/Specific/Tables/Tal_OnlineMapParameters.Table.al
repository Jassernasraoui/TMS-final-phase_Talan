table 73650 "Online Map Parameters"
{
    Caption = 'Online Map Parameter Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Map Service"; Text[250])
        {
            Caption = 'Map Service';
            DataClassification = CustomerContent;
        }
        field(4; "Directions Service"; Text[250])
        {
            Caption = 'Directions Service';
            DataClassification = CustomerContent;
        }
        field(5; "Directions from Location Service"; Text[250])
        {
            Caption = 'Directions from Location Service';
            DataClassification = CustomerContent;
        }
        field(6; "URL Encoding"; Boolean)
        {
            Caption = 'URL Encoding';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(7; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(8; "Is Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Is Default" then
            SetAllDefaultsToFalse();
    end;

    trigger OnModify()
    begin
        if "Is Default" then
            SetAllDefaultsToFalse();
    end;

    local procedure SetAllDefaultsToFalse()
    var
        OnlineMapParam: Record "Online Map Parameters";
    begin
        OnlineMapParam.Reset();
        OnlineMapParam.SetFilter(Code, '<>%1', Code);
        OnlineMapParam.SetRange("Is Default", true);

        if OnlineMapParam.FindSet() then
            repeat
                OnlineMapParam."Is Default" := false;
                OnlineMapParam.Modify();
            until OnlineMapParam.Next() = 0;
    end;
}