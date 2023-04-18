class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      next if item.name == "Sulfuras, Hand of Ragnaros"
      if item.name == "Conjured Mana Cake"
         decrement_sell_in(item)
         decrement_quality(item, (item.sell_in < 0) ? 4 : 2)
      elsif item.name == "Aged Brie"
         decrement_sell_in(item)
         increment_quality(item, (item.sell_in < 0) ? 2 : 1)
      else
        if item.name != "Backstage passes to a TAFKAL80ETC concert"
          decrement_quality(item, 1)
        else
          if item.quality < 50
            item.quality = item.quality + 1
            if item.name == "Backstage passes to a TAFKAL80ETC concert"
              if item.sell_in < 11
                increment_quality(item)
              end
              if item.sell_in < 6
                increment_quality(item)
              end
            end
          end
        end
        item.sell_in = item.sell_in - 1
        if item.sell_in < 0
          if item.name != "Backstage passes to a TAFKAL80ETC concert"
            decrement_quality(item, 1)
          else
            item.quality = item.quality - item.quality
          end
        end
      end
    end
  end

  def decrement_sell_in(item)
    item.sell_in = item.sell_in - 1
    item
  end

  def decrement_quality(item, amount)
     item.quality = item.quality - amount < 0 ? 0 : item.quality - amount
     item
  end

  def increment_quality(item, amount=1)
    item.quality = item.quality + amount > 50 ? 50 : item.quality + amount
    item
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
