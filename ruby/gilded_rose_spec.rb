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
end
