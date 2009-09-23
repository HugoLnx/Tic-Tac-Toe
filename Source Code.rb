class TrueClass
  def orx(cond)
    return !cond
  end  
end
class FalseClass
  def orx(cond)
    return cond
  end    
end

class Array
  def count
    count = 0
    self.each{|slot| count += 1 if yield(slot)}
    return count
  end  
end

class Array_Btns < Array
  def by_c(x,y)
    return self[x + y*3]
  end
  def by_t(type)
    return self.find_all{|slot| slot.type == type}[0]
  end  
end  
require 'gtk2'
module Gtk

class Label
  attr_reader :markup
  alias ori_set_markup set_markup
  def set_markup(markup)
    @markup = markup
    ori_set_markup(@markup)
  end 
end  
  
  
  class ToolButton
    attr_reader :x, :y, :type
    alias ori_init initialize
    def initialize(icon,markup,x,y)
      @type = []
      if x == 1 and y == 1
        @type = ["center"]
      elsif (x == 0 or x == 2) and (y == 0 or y == 2)
        @type[0] = "tip"
        if y == 0
          @type[2] = "top"
        else
          @type[2] = "bottom"
        end
        if x == 0
          @type[1] = "left"
        else
          @type[1] = "right"
        end  
      else
        @type[0] = "side"
        if y == 0
          @type[2] = "top"
        elsif y == 2
          @type[2] = "bottom"
        elsif x == 0
          @type[1] = "left"
        else
          @type[1] = "right"
        end  
      end
      
      @x = x
      @y = y
      ori_init(icon,"")
      self.label_widget = Label.new.set_markup(markup)
    end
    def marked?(mark_markup)
      return self.label_widget.markup == mark_markup
    end  
  end
end


class Human
  attr_reader :id, :mark_markup
  def initialize(mark_markup,id)
    @mark_markup = mark_markup
    @waiting = false
    @id = id
  end

  def human?
    return self.class == Human
  end  
  
  def turn(btns,choiced=nil)
    $num_moves += 1
    valid = btns.find_all{|btn| btn.label_widget.markup == $Null_markup}
    if valid.include?(choiced)
      return choiced
    end  
  end
end

class CPU < Human
  alias ori_init initialize
  def initialize(mark_markup,id,btns)
    @strategy = 0
    @o_markup = mark_markup == $X_markup ? $O_markup : $X_markup
    @btns = btns
    @my_lst_btn = nil
    ori_init(mark_markup,id)
  end
  
  def turn(btns,choiced=nil)
    @choiced = nil
    $num_moves += 1
    @btns = btns
    if $num_moves > 2 and $nivel != 0
      @choiced = take_care_of_checkmate("try_do") if $nivel >= 2
      if @choiced == nil
        @choiced = take_care_of_checkmate("previne") if $nivel >= 1
      end  
      return @choiced if @choiced != nil
    end
    valid = @btns.find_all{|btn| btn.label_widget.markup == $Null_markup}
    valid = use_invincible_strategies(valid) if $nivel >= 3
    @choiced = valid.class == Array ? valid[rand(valid.size - 1)] : valid
    return @choiced
  ensure
    @my_lst_btn = @choiced
  end
  
  def oposit(direction)
    if direction == "top"
      return "bottom"
    elsif direction == "bottom"
      return "top"
    elsif direction == "right"
      return "left"
    elsif direction == "left"
      return "right"
    end
    return nil
  end  
  
  def use_invincible_strategies(valid)
    
    if $num_moves == 0
      valid = valid.find_all{|btn| btn.type[0] == "tip" or btn.type[0] == "center"}
    end
    
    if $num_moves == 2
      if @my_lst_btn.type[0] == "center"
        if $last_btn.type[0] == "tip"
          return @btns.by_t(["tip",oposit($last_btn.type[1]),oposit($last_btn.type[2])])
        elsif $last_btn.type[0] == "side"
          valid = valid.find_all{|btn| btn.type[0] == "tip"}
          if $last_btn.type[1] != nil
            valid = valid.find_all{|btn| btn.type[1] == oposit($last_btn.type[1])}
          else
            valid = valid.find_all{|btn| btn.type[2] == oposit($last_btn.type[2])}
          end
        end
      elsif @my_lst_btn.type[0] == "tip"
        if $last_btn.type[1] == oposit(@my_lst_btn.type[1]) and $last_btn.type[2] == 
        oposit(@my_lst_btn.type[2])
          @strategy = 1
          valid = valid.find_all{|btn| btn.type[0] == "tip"}
        elsif $last_btn.type[0] == "center" or $last_btn.type[0] == "tip"
          @choiced = @btns.by_t(["tip",oposit(@my_lst_btn.type[1]),oposit(@my_lst_btn.
          type[2])])
          return @choiced
        else
          @strategy = 2
          if $last_btn.type[1] != nil
            @choiced = @btns.by_t(["tip",oposit($last_btn.type[1]),@my_lst_btn.type[2]])
          else
            @choiced = @btns.by_t(["tip",@my_lst_btn.type[1],oposit($last_btn.type[2])])
          end
          return @choiced
        end
      end  
    end
    
    if $num_moves == 4
      if @strategy == 1
        return @choiced = valid.find_all{|btn| btn.type[0] == "tip"}[0]
      elsif @strategy == 2
        @choiced = @btns.by_t(["center"])
        return @choiced
      end  
    end
    if $num_moves == 1
      if $last_btn.type[0] == "center"
        valid = valid.find_all{|btn| btn.type[0] == "tip"}
      else
        @strategy = [1,$last_btn] if $last_btn.type[0] == "side"
        @choiced = @btns.by_t(["center"])
        return @choiced
      end
    end
    if $num_moves == 3
      if $last_btn.type[1] == oposit(@my_lst_btn.type[1]) and $last_btn.type[2] == 
      oposit(@my_lst_btn.type[2])
        valid = valid.find_all{|btn| btn.type[0] == "tip"}
      end
      if @btns.count{|btn| btn.type[0] == "tip" and btn.label_widget.markup == 
        @o_markup} == 2
        valid = valid.find_all{|btn| btn.type[0] == "side"}
      end
      if @strategy[0] == 1
        first_btn = @strategy[1]
        if (first_btn.type[1] == nil).orx($last_btn.type[1] == nil)
          if first_btn.type[1] == nil
            @choiced = @btns.by_t(["tip",$last_btn.type[1],first_btn.type[2]])
          else
            @choiced = @btns.by_t(["tip",first_btn.type[1],$last_btn.type[2]])
          end
          return @choiced
        else
          valid = valid.find_all{|btn| btn.type[0] == "tip"}
        end  
      end  
    end
    return valid
  end  
  
  def take_care_of_checkmate(type)
    if type == "previne"
      lst_btn = $last_btn
      compare_markup = @o_markup
    else
      lst_btn = @my_lst_btn
      compare_markup = @mark_markup
    end  
    x = lst_btn.x
    y = lst_btn.y
    null_btn = nil
    if x == 0
      null_btn = check_2_btns(@btns.by_c(x + 1,y),@btns.by_c(x + 2,y),compare_markup)
    elsif x == 1
      null_btn = check_2_btns(@btns.by_c(x + 1,y),@btns.by_c(x - 1,y),compare_markup)
    else
      null_btn = check_2_btns(@btns.by_c(x - 1,y),@btns.by_c(x - 2,y),compare_markup)
    end
    if null_btn == nil
      if y == 0 
        null_btn = check_2_btns(@btns.by_c(x,y + 1),@btns.by_c(x,y + 2),compare_markup)
      elsif y == 1
        null_btn = check_2_btns(@btns.by_c(x,y + 1),@btns.by_c(x,y - 1),compare_markup)
      else
        null_btn = check_2_btns(@btns.by_c(x,y - 1),@btns.by_c(x,y - 2),compare_markup)
      end  
    else
      return null_btn
    end  
    if null_btn == nil
      if x == 0 and y == 0
        null_btn = check_2_btns(@btns.by_c(1,1),@btns.by_c(2,2),compare_markup)
      elsif x == 2 and y == 2
        null_btn = check_2_btns(@btns.by_c(0,0),@btns.by_c(1,1),compare_markup)
      elsif x == 2 and y == 0
        null_btn = check_2_btns(@btns.by_c(1,1),@btns.by_c(0,2),compare_markup)
      elsif x == 0 and y == 2
        null_btn = check_2_btns(@btns.by_c(1,1),@btns.by_c(2,0),compare_markup)
      elsif x == 1 and y == 1
        null_btn = check_2_btns(@btns.by_c(0,0),@btns.by_c(2,2),compare_markup)
        return null_btn if null_btn != nil
        null_btn = check_2_btns(@btns.by_c(2,0),@btns.by_c(0,2),compare_markup)
      end  
    end  
    return null_btn
  end

  def check_2_btns(btn1,btn2,compare_markup)
    b1_mark = btn1.label_widget.markup
    b2_mark = btn2.label_widget.markup
    null_btn = nil
    enemy_btn = nil
    if b1_mark != b2_mark
      if b1_mark == $Null_markup
        null_btn = btn1
      elsif b2_mark == $Null_markup
        null_btn = btn2
      end
      if b1_mark == compare_markup
        enemy_btn = btn1
      elsif b2_mark == compare_markup
        enemy_btn = btn2
      end
      if null_btn == nil or enemy_btn == nil
        null_btn = nil
        enemy_btn = nil
      end  
    end
    return null_btn
  end     
  
end  


 
  #############################################################
  ## Declaração de Variáveis
  #############################################################
  $nivel = 3
  $num_moves = -1
  @btns = Array_Btns.new
  $Null_markup = "<span face='Lucida Console' size='50'> </span>"
  $X_markup = "<span face='Lucida Console' size='50'>X</span>"
  $O_markup = "<span face='Lucida Console' size='50'>O</span>"
  
  #############################################################
  ## Declaração de Componentes
  #############################################################

  @window = Gtk::Window.new("Jogo da Velha")
  @window.set_default_size(300,300)
  @msg_window = Gtk::Window.new("Jogo da Velha")
  @msg_window.resizable = false
  @msg_window.modal = true
  @lbl_rslt = Gtk::Label.new("")
  table = Gtk::Table.new(8,8)
  (0..8).each{|i|
    @btns[i] = Gtk::ToolButton.new(nil,$Null_markup,i - Integer(i/3)*3,Integer(i/3))
  }
  
  player = []
  player[1] = CPU.new($X_markup,1,@btns)#Human.new($X_markup,1)#
  player[0] = Human.new($O_markup,0)#CPU.new($O_markup,1)
  @act_player = player[0]
  #############################################################
  ## Declaração de Métodos do Main
  #############################################################
  
  def victory?(btns)
    x = $last_btn.x
    y = $last_btn.y
    vic = false
    if x == 0
      vic = check_2_btns(@btns.by_c(x + 1,y),@btns.by_c(x + 2,y))
    elsif x == 1
      vic = check_2_btns(@btns.by_c(x + 1,y),@btns.by_c(x - 1,y))
    else
      vic = check_2_btns(@btns.by_c(x - 1,y),@btns.by_c(x - 2,y))
    end
    if vic == false
      if y == 0 
        vic = check_2_btns(@btns.by_c(x,y + 1),@btns.by_c(x,y + 2))
      elsif y == 1
        vic = check_2_btns(@btns.by_c(x,y + 1),@btns.by_c(x,y - 1))
      else
        vic = check_2_btns(@btns.by_c(x,y - 1),@btns.by_c(x,y - 2))
      end  
    else
      return vic
    end  
    if vic == false
      if x == 0 and y == 0
        vic = check_2_btns(@btns.by_c(1,1),@btns.by_c(2,2))
      elsif x == 2 and y == 2
        vic = check_2_btns(@btns.by_c(0,0),@btns.by_c(1,1))
      elsif x == 2 and y == 0
        vic = check_2_btns(@btns.by_c(1,1),@btns.by_c(0,2))
      elsif x == 0 and y == 2
        vic = check_2_btns(@btns.by_c(1,1),@btns.by_c(2,0))
      elsif x == 1 and y == 1
        vic = check_2_btns(btns.by_c(0,0),btns.by_c(2,2))
        return vic if vic != false
        vic = check_2_btns(@btns.by_c(2,0),@btns.by_c(0,2))
      end  
    end  
    return vic
  end  

  def check_2_btns(btn1,btn2)
    b1_mark = btn1.label_widget.markup
    b2_mark = btn2.label_widget.markup
    if b1_mark == b2_mark and b1_mark == $last_btn.label_widget.markup
      return true
    else
      return false
    end  
  end     
  
  #############################################################
  ## Configuração de componentes
  #############################################################
  @window.resizable = false
  #############################################################
  ## Declaração de Sinais
  #############################################################
  @msg_window.signal_connect("delete_event"){
    $num_moves = -1
    @btns.each{|btn| btn.label_widget.set_markup($Null_markup)}
    @act_player = player[0]
    @msg_window.hide
  }
  @window.signal_connect("delete_event"){Gtk.main_quit}
  if !@act_player.human?
    choiced = @act_player.turn(@btns,nil)
    choiced.label_widget.set_markup(@act_player.mark_markup)
    @act_player = @act_player.id == 0 ? player[1] : player[0]
  end  
  (0..8).each{|i|
    @btns[i].signal_connect("clicked"){|w|
      click_used = false
      if w.label_widget.markup == $Null_markup
        if @act_player.human?
          widget = @act_player.turn(@btns,w)
          $last_btn = widget
          widget.label_widget.set_markup(@act_player.mark_markup)
          @act_player = @act_player.id == 0 ? player[1] : player[0]
          click_used = check_victory
        end
        if !@act_player.human? and click_used and $num_moves < 8
          choiced = @act_player.turn(@btns,w)
          $last_btn = choiced
          choiced.label_widget.set_markup(@act_player.mark_markup)
          @act_player = @act_player.id == 0 ? player[1] : player[0]
          click_used = true
          check_victory
        end
      end
    }
  }
  def check_victory
    if victory?(@btns)
      @lbl_rslt.set_text("Player #{@act_player.mark_markup == $X_markup ? 'O' : 'X'} Ganhou")
      @msg_window.show_all
      return false
    elsif $num_moves >= 8
      @lbl_rslt.set_text("Deu Velha")
      @msg_window.show_all
    end
    return true
  end  
  #############################################################
  ## Englobação dos Componentes
  #############################################################
  @msg_window.add(@lbl_rslt)
  (0..8).each{|i|
  x = @btns[i].x
  y = @btns[i].y
  table.attach(@btns[i],(x*2)+1,(x*2)+2,(y*2)+1,(y*2)+2)
  }
  (0..3).each{|i|
    table.attach(Gtk::VSeparator.new,i*2,(i*2)+1,0,8)
    table.attach(Gtk::HSeparator.new,0,8,i*2,(i*2)+1)   
  }

  @window.add(table)
  #############################################################
  ## Demonstração dos Componentes
  #############################################################
  @window.show_all
  
  #############################################################
  ## Passa Controle Para Gtk
  #############################################################
  Gtk.main