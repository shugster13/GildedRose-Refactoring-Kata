require File.join(File.dirname(__FILE__), 'gilded_rose')

describe GildedRose do

  let(:generic_item) { Item.new("foo", 0, 0) }
  let(:generic_item2) { Item.new("bar", 0, 5) }
  let(:generic_item3) { Item.new("sundance", 4, 10) }
  let(:generic_items_list) { [ generic_item, generic_item2, generic_item3 ] }

  shared_examples "all items" do
    it "does not change the names" do
      names = items.map(&:name)
      gr = GildedRose.new(items)
      gr.update_quality()
      names.each_with_index do | orig_name, idx |
        #puts "Orig Name [#{orig_name}]"
        expect(items[idx].name).to eq orig_name
      end
    end
  end

  shared_examples "an item whose sell_in reduces" do
    it "does reduce the sell_in" do
      gr = GildedRose.new(items)
      starting_sell_ins = items.map(&:sell_in)
      (1..3).each do | count|
        gr.update_quality()
        starting_sell_ins.each_with_index do | si, si_idx |
          expect(items[si_idx].sell_in).to eq si - count
        end
      end
    end
  end

  shared_examples "an item whose quality reduces" do
    it "reduces by 1 when sell_in > -1, then by 2 but does not set the quality to less than zero" do
      gr = GildedRose.new(items)
      starting_qualities = items.map(&:quality)
      incremental_reduction = 0
      (1..3).each do | count |
        gr.update_quality()
        starting_qualities.each_with_index do | sq, sq_idx |
          if items[sq_idx].sell_in < 0
            # reduction is twice as fast when sell_in is negative
            inc_reduction = count * 2
            #inc_reduction = count - items[sq_idx].sell_in
            #puts "Sell_In is negative #{items[sq_idx].sell_in}, inc_red [#{inc_reduction}]"
          else
            inc_reduction = count
            #puts "inc_red [#{inc_reduction}]"
          end
          expect(items[sq_idx].quality).to eq(sq - inc_reduction > -1 ? sq - inc_reduction : 0)
        end
      end
    end
  end

  describe "a generic item" do
    let(:items) { generic_items_list }
    it_behaves_like "all items"
    it_behaves_like "an item whose sell_in reduces"
    it_behaves_like "an item whose quality reduces"
  end

  describe "Sulfuras, Hand of Ragnaros" do
    let(:sulfuras_item) { Item.new("Sulfuras, Hand of Ragnaros", 0, 80) }
    let(:sulfuras_item1) { Item.new("Sulfuras, Hand of Ragnaros", 3, 80) }
    let(:items) { [ sulfuras_item, sulfuras_item1 ] }

    it "does not modify sell_in or quality" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[0].sell_in).to eq 0
      expect(items[0].quality).to eq 80
      expect(items[1].sell_in).to eq 3
      expect(items[1].quality).to eq 80
      gr.update_quality()
      expect(items[0].sell_in).to eq 0
      expect(items[0].quality).to eq 80
      expect(items[1].sell_in).to eq 3
      expect(items[1].quality).to eq 80
    end

    it_behaves_like "all items"
  end

  describe "Aged Brie" do
    let(:aged_brie_item) { Item.new("Aged Brie", 10, 48) }
    let(:aged_brie_item1) { Item.new("Aged Brie", 1, 48) }
    let(:items) { [ aged_brie_item, aged_brie_item1 ] }

    it "increases quality by 1 until it reaches a maximum of 50 regardless of sell_in" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[0].sell_in).to eq 9
      expect(items[0].quality).to eq 49
      expect(items[1].sell_in).to eq 0
      expect(items[1].quality).to eq 49
      gr.update_quality()
      expect(items[0].sell_in).to eq 8
      expect(items[0].quality).to eq 50
      expect(items[1].sell_in).to eq -1
      expect(items[1].quality).to eq 50
      gr.update_quality()
      expect(items[0].sell_in).to eq 7
      expect(items[0].quality).to eq 50
      expect(items[1].sell_in).to eq -2
      expect(items[1].quality).to eq 50
    end

    it_behaves_like "all items"
  end

  describe "Backstage passes to a TAFKAL80ETC concert" do
    let(:bsp_item) { Item.new("Backstage passes to a TAFKAL80ETC concert", 11, 20) }
    let(:bsp_item1) { Item.new("Backstage passes to a TAFKAL80ETC concert", 6, 44) }
    let(:bsp_item2) { Item.new("Backstage passes to a TAFKAL80ETC concert", 1, 10) }
    let(:items) { [ bsp_item, bsp_item1 ] }

    it "increases quality by 1 when sell in is greater than 10" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[0].sell_in).to eq 10
      expect(items[0].quality).to eq 21
    end

    it "increases quality by 2 when sell in is 10 days or less but more than 5 days" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[0].sell_in).to eq 10
      expect(items[0].quality).to eq 21
      gr.update_quality()
      expect(items[0].sell_in).to eq 9
      expect(items[0].quality).to eq 23
    end

    it "increases quality by 3 when sell in is 5 days or less but more than 0 days but does not pass a maximum of 50" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[1].sell_in).to eq 5
      expect(items[1].quality).to eq 46
      gr.update_quality()
      expect(items[1].sell_in).to eq 4
      expect(items[1].quality).to eq 49
      gr.update_quality()
      expect(items[1].sell_in).to eq 3
      expect(items[1].quality).to eq 50
    end

    it "sets quality to zero when sell in has reached zero" do
      gr = GildedRose.new([ bsp_item2 ])
      gr.update_quality()
      expect(bsp_item2.sell_in).to eq 0
      expect(bsp_item2.quality).to eq 13
      gr.update_quality()
      expect(bsp_item2.sell_in).to eq -1
      expect(bsp_item2.quality).to eq 0
    end

    it_behaves_like "all items"
  end

  describe "Conjured Mana Cake" do
    let(:con_item) { Item.new("Conjured Mana Cake", 10, 48) }
    let(:con_item1) { Item.new("Conjured Mana Cake", 1, 30) }
    let(:con_item2) { Item.new("Conjured Mana Cake", 1, 7) }
    let(:items) { [ con_item, con_item1, con_item2 ] }

    it "reduces quality by 2 when sell_in > -1, then by -4 to a minimum of 0" do
      gr = GildedRose.new(items)
      gr.update_quality()
      expect(items[0].sell_in).to eq 9
      expect(items[0].quality).to eq 46
      expect(items[1].sell_in).to eq 0
      expect(items[1].quality).to eq 28
      expect(items[2].sell_in).to eq 0
      expect(items[2].quality).to eq 5
      gr.update_quality()
      expect(items[0].sell_in).to eq 8
      expect(items[0].quality).to eq 44
      expect(items[1].sell_in).to eq -1
      expect(items[1].quality).to eq 24
      expect(items[2].sell_in).to eq -1
      expect(items[2].quality).to eq 3
      gr.update_quality()
      expect(items[0].sell_in).to eq 7
      expect(items[0].quality).to eq 42
      expect(items[1].sell_in).to eq -2
      expect(items[1].quality).to eq 20
      expect(items[2].sell_in).to eq -2
      expect(items[2].quality).to eq 0
    end

    it_behaves_like "all items"
  end
end
