page 73515 RoleCenterHeadline
{
    PageType = HeadLinePart;

    layout
    {
        area(content)
        {
            field(Headline1; hdl1Txt)
            {
                ApplicationArea = all;
            }
            field(Headline2; hdl2Txt)
            {
                ApplicationArea = all;
            }
            field(Headline3; hdl3Txt)
            {
                ApplicationArea = all;
            }
            field(Headline4; hdl4Txt)
            {
                ApplicationArea = all;
            }
        }
    }

    var
        hdl1Txt: Label 'Hello, Welcome to TMS Role Center ! ';
        hdl2Txt: Label 'Transport Managament System';
        hdl3Txt: Label 'TMS Role Center';
        hdl4Txt: Label 'TMS Role Center';
}