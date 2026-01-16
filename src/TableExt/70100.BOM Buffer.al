tableextension 70100 "BOM Buffer" extends "BOM Buffer"
{
    fields
    {
        field(70100; TopLevelItem; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70101; ParentItem; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70102; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
            OptimizeForTextSearch = true;
        }
    }
}