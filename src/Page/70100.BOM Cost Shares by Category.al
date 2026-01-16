page 70100 "BOM Cost Shares by Category"
{
    Caption = 'BOM Cost Shares by Item Category';
    PageType = Worksheet;
    SourceTable = "BOM Buffer";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            grid(Options)
            {
                Caption = 'Options';

                field(ItemCategoryFilter; ItemCategoryFilter)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Item Category Code';
                    ToolTip = 'Specifies the item category for which BOM cost shares are shown.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemCategory: Record "Item Category";
                        ItemCategoryList: Page "Item Categories";
                    begin
                        ItemCategoryList.LookupMode := true;
                        ItemCategoryList.SetTableView(ItemCategory);

                        if ItemCategoryList.RunModal() = ACTION::LookupOK then begin
                            ItemCategoryList.GetRecord(ItemCategory);
                            Text := ItemCategory.Code;
                            exit(true);
                        end;

                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        // Clear Item filter when category changes
                        ItemFilter := '';
                        UpdatePage();
                    end;
                }

                field(ItemFilter; ItemFilter)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the item that is shown in the BOM Cost Shares window.';
                    //  Enabled = ItemCategoryFilter <> '';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record Item;
                        ItemList: Page "Item List";
                    begin
                        ItemRec.Reset();

                        // 🔹 Filter items by category if selected
                        if ItemCategoryFilter <> '' then
                            ItemRec.SetRange("Item Category Code", ItemCategoryFilter);

                        ItemList.SetTableView(ItemRec);
                        ItemList.LookupMode := true;

                        if ItemList.RunModal() = ACTION::LookupOK then begin
                            ItemList.GetRecord(ItemRec);
                            Text := ItemRec."No.";
                            exit(true);
                        end;

                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        UpdatePage();
                    end;
                }
            }

            repeater(Lines)
            {
                Caption = 'Lines';
                IndentationColumn = Rec.Indentation;
                ShowAsTree = true;

                field(Type; Rec.Type)
                {
                    ApplicationArea = Assembly;
                }
                field(Indentation; Rec.Indentation)
                {
                    Caption = 'Level';
                    ApplicationArea = all;
                }
                field(TopLevelItem; Rec.TopLevelItem)
                {
                    Caption = 'Top Level Item';
                    ApplicationArea = All;
                }

                field(ParentItem; Rec.ParentItem)
                {
                    Caption = 'Parent Item';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;

                }


                field(Description; Rec.Description)
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;
                }

                field("Qty. per Parent"; Rec."Qty. per Parent")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0 : 5;
                }
                field("Rolled-up Capacity Ovhd. Cost"; rec."Rolled-up Capacity Ovhd. Cost")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Qty. per Top Item"; Rec."Qty. per Top Item")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Unit Cost"; rec."Unit Cost")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(MaterialCost; MC)
                {
                    Caption = 'Material Cost';
                    ApplicationArea = all;
                    Editable = false;
                }
                field(DirectUnitCost; DUC)
                {
                    Caption = 'Direct Unit Cost';
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Overhead Rate"; Orate)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Rolled-up Material Cost"; Rec."Rolled-up Material Cost")
                {
                    ApplicationArea = Assembly;
                }

                field("Rolled-up Capacity Cost"; Rec."Rolled-up Capacity Cost")
                {
                    ApplicationArea = Assembly;
                }

                field("Rolled-up Subcontracted Cost"; Rec."Rolled-up Subcontracted Cost")
                {
                    ApplicationArea = Manufacturing;
                }

                field("Rolled-up Mfg. Ovhd Cost"; Rec."Rolled-up Mfg. Ovhd Cost")
                {
                    ApplicationArea = Manufacturing;
                }

                field("Rolled-up Scrap Cost"; Rec."Rolled-up Scrap Cost")
                {
                    ApplicationArea = Manufacturing;
                }

                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = Assembly;
                }
            }
        }

    }

    actions
    {
        area(processing)
        {
            action("Show Warnings")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Warnings';
                Image = ErrorLog;

                trigger OnAction()
                begin
                    ShowWarningsForAllLines();
                end;
            }
        }

        area(reporting)
        {
            action("BOM Cost Share Distribution")
            {
                ApplicationArea = Assembly;
                Caption = 'BOM Cost Share Distribution';
                Image = Report;

                trigger OnAction()
                begin
                    ShowBOMCostShareDistribution();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        DummyBOMWarningLog: Record "BOM Warning Log";
        ItemC: Record Item;
    begin
        IsParentExpr := not Rec."Is Leaf";
        HasWarning := not Rec.IsLineOk(false, DummyBOMWarningLog);

        ItemC.Reset();
        ItemC.SetRange("No.", Rec."No.");
        If ItemC.FindFirst() then begin
            Rec."Item Category Code" := ItemC."Item Category Code";
            Rec.Modify();
        end;
        if rec.Type = rec.type::Item then
            if Itemlist.get(rec."No.") then begin
                MC := Itemlist."Unit Cost";
                orate := Itemlist."Overhead Rate";
            end;
        if rec.Type = rec.type::"Work Center" then begin
            if wc.get(rec."No.") then begin
                DUC := WC."Direct Unit Cost";
                ORate := wc."Overhead Rate";
            end;
        end;
    end;

    trigger OnOpenPage()
    begin
        UpdatePage();
    end;

    var
        Item: Record Item;
        Itemlist: Record item;
        WC: Record "Work Center";
        MC: Decimal;
        DUC: Decimal;
        ORate: Decimal;
        TopItem: Code[20];
        ParentItem: Code[20];
        ParentItem2: Code[20];
        IsParentExpr: Boolean;
        HasWarning: Boolean;
        ItemCategoryFilter: Code[250];
        ItemFilter: Code[250];
        LevelItemNo: array[10] of Code[20];
        DisplayTopItem: Code[20];
        DisplayParentItem: Code[20];
        CurrentRootItem: Code[20];
        Text000: Label 'None of the items in the selected filter have a BOM.';
        Text001: Label 'There are no warnings.';

    local procedure UpdatePage()
    var
        CalcBOMTree: Codeunit "Calculate BOM Tree";
        HasBOM: Boolean;
    begin
        // Rec.Reset();
        // Rec.DeleteAll();

        // // Nothing selected
        // if (ItemCategoryFilter = '') and (ItemFilter = '') then
        //     exit;

        Rec.Reset();
        Rec.DeleteAll();

        // If both filters blank → clear page and refresh
        if (ItemCategoryFilter = '') and (ItemFilter = '') then begin
            CurrPage.Update(false);
            exit;
        end;

        Item.Reset();
        Item.SetRange("Date Filter", 0D, WorkDate());

        if ItemCategoryFilter <> '' then
            Item.SetRange("Item Category Code", ItemCategoryFilter);

        if ItemFilter <> '' then
            Item.SetFilter("No.", ItemFilter);

        if not Item.FindSet() then
            Error('No items found for the selected filters.');

        repeat
            if Item.HasBOM() or Item.HasRoutingNo() then
                HasBOM := true;
        until (Item.Next() = 0) or HasBOM;

        if not HasBOM then
            Error(Text000);

        // Reapply filters for BOM generation
        Item.Reset();
        Item.SetRange("Date Filter", 0D, WorkDate());

        if ItemCategoryFilter <> '' then
            Item.SetRange("Item Category Code", ItemCategoryFilter);

        if ItemFilter <> '' then
            Item.SetFilter("No.", ItemFilter);

        CalcBOMTree.GenerateTreeForManyItems(Item, Rec, "BOM Tree Type"::Cost);

        CurrPage.Update(false);
    end;

    local procedure ShowBOMCostShareDistribution()
    var
        Item2: Record Item;
    begin
        Rec.TestField(Type, Rec.Type::Item);
        Item2.Get(Rec."No.");
        REPORT.Run(REPORT::"BOM Cost Share Distribution", true, true, Item2);
    end;

    local procedure ShowWarningsForAllLines()
    var
        TempBOMWarningLog: Record "BOM Warning Log" temporary;
    begin
        if Rec.AreAllLinesOk(TempBOMWarningLog) then
            Message(Text001)
        else
            PAGE.RunModal(PAGE::"BOM Warning Log", TempBOMWarningLog);
    end;
}