table 77015 TripScedulingCueTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PrimaryKey; Code[250])
        {

            DataClassification = ToBeClassified;
        }
        field(2; TripScedulingPlannified; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER(Plannified)));

        }
        field(3; TripScedulingOnMission; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER("On Mission")));

        }
        field(4; TripScedulingStopped; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planification Header" where(Statut = FILTER(Stopped)));

        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }
}