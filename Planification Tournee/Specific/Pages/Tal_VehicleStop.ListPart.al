page 77001 "Vehicle Stop List"
{
    PageType = ListPart;
    SourceTable = "vehicle Stop Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Stop No."; rec."Stop No.") { }
                field("Customer No."; rec."Customer No.") { }
                field("Delivery Address"; rec."Delivery Address") { }
                field("Estimated Arrival Time"; rec."Estimated Arrival Time") { }
                field("Estimated Departure Time"; rec."Estimated Departure Time") { }
                field("Quantity to Deliver"; rec."Quantity to Deliver") { }
                field("Remarks"; rec."Remarks") { }
            }
        }
    }
}
