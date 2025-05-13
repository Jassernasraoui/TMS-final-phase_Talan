enum 77001 "Driver License Type"
{
    Extensible = true;

    value(1; "License B")
    {
        Caption = 'License B-Cars and light vehicles';
    }

    // value(1; "License A1")
    // {
    //     Caption = 'License A1 -Light motorcycles';
    // }

    // value(2; "License A2")
    // {
    //     Caption = 'License A2 - Motorcycles';
    // }

    value(0; "License A")
    {
        Caption = 'License A - Motorcycles with no power limit';
    }

    // value(4; "License C1")
    // {
    //     Caption = 'License C1 - Medium trucks';
    // }

    value(2; "License C")
    {
        Caption = 'License C - Heavy trucks';
    }

    value(3; "License D")
    {
        Caption = 'License D - Buses';
    }

    value(8; "License BE")
    {
        Caption = 'License BE - Car with trailer';
    }

    value(9; "License CE")
    {
        Caption = 'License CE - Heavy truck with trailer';
    }

    value(10; "License DE")
    {
        Caption = 'License DE - Bus with trailer';
    }

    value(11; "License L")
    {
        Caption = 'License L - Agricultural vehicles';
    }
}
