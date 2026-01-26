pageextension 70100 McDPurchInv extends "Purchase Invoice"
{
    layout
    {
        AddAfter("Status")
        {
            field("McD Doc Matched"; Rec.McDDocMatched)
            {
                Caption = 'Continia Match';
                ApplicationArea = all;
                Visible = true;
                Editable = false;
            }
        }
    }
}
