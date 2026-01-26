pageextension 70101 McDProductionBom extends "Production BOM"
{
    layout
    {
        // Hide orginal field to override OnDrillDown
        modify(Status)
        {
            Visible = false;
        }

        addafter(Status)
        {
            field(McDStatus; Rec.McDStatus)
            {
                Caption = 'Status';
                ApplicationArea = Basic, Suite;
                ShowCaption = false;

            }
        }
    }
}
