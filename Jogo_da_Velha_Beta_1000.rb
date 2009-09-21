#
# [Author] HugoLnx/HugoLinux
#

# Array class
class Array
  # [Receive] <b>+Block_of_Commands+</b>
  # [Return] <b>+Integer+:</b> The quantity of elements of Array that make the block of commands true.
  def count
    count = 0
    self.each{|slot| count += 1 if yield(slot)}
    return count
  end  
end


require 'gtk2'

# Graphic Interface
module Gtk
  class Label
    # Special formatation for the text in label
    attr_reader :markup
    alias ori_set_markup set_markup
    # [Brief] Update the @markup when it's used the set_markup    
    # [Receive] <b>+String+:</b>markup
    # [Return] <html><font color=red>Nothing</font></html>
    def set_markup(markup)
      @markup = markup
      ori_set_markup(@markup)
    end 
  end    
end

# This class represent's the player
class Player
  # <b>+Integer+:</b> Identificação que se dá à instancia dessa classe
  attr_accessor :id
  # <b>+String+:</b> Representa a marca utilizada pelo jogador
  attr_accessor :mark_markup
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+Boolean+:</b> if the instance is a human player or not.
  def human?
    return self.class == Player
  end
end


# This class represent's a CPU player
class CPU < Player
  alias ori_init initialize
  # [Brief] Boots the local variables  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def initialize
    @strategy = 0
    @my_lst_btn = nil
    ori_init
  end
  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+Object+:</b> The button choiced by Artificial Inteligence
  def turn
    @choiced = nil
    @o_markup = mark_markup == $X_markup ? $O_markup : $X_markup
    $num_moves += 1
    if $num_moves > 2 and $nivel != 0
      @choiced = take_care_of_checkmate("try_do") if $nivel >= 2
      if @choiced.nil?
        @choiced = take_care_of_checkmate("previne") if $nivel >= 1
      end  
      return @choiced if @choiced != nil
    end
    valid = $btns.find_all{|btn| btn.label_widget.markup == $Null_markup}
    valid = use_invincible_strategies(valid) if $nivel == 3
    @choiced = valid[rand(valid.size - 1)]
    return @choiced
  ensure
    @my_lst_btn = @choiced
  end
  
  # [Receive] <b>+String+:</b> Direction
  # [Return] <b>+String+:</b> The opost direction
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
  # Aplica estratégias que tornam a CPU invencível.
  # [Return] <b>+Array+:</b> All the buttons that can be played
  def use_invincible_strategies(valid)
    if $num_moves == 0
      return valid.find_all{|btn| btn.type[0] == "tip" or btn.type[0] == "center"}
    end
    
    if $num_moves == 2
      if @my_lst_btn.type[0] == "center"
        if $last_btn.type[0] == "tip"
          return [$btns.by_t(["tip",oposit($last_btn.type[1]),oposit($last_btn.type[2])])]
        elsif $last_btn.type[0] == "side"
          return valid.find_all{|btn| btn.type[0] == "tip"}
          if $last_btn.type[1] != nil
            return valid.find_all{|btn| btn.type[1] == oposit($last_btn.type[1])}
          else
            return valid.find_all{|btn| btn.type[2] == oposit($last_btn.type[2])}
          end
        end
      elsif @my_lst_btn.type[0] == "tip"
        if $last_btn.type[1] == oposit(@my_lst_btn.type[1]) and $last_btn.type[2] == 
        oposit(@my_lst_btn.type[2])
          @strategy = 1
          return valid.find_all{|btn| btn.type[0] == "tip"}
        elsif $last_btn.type[0] == "center" or $last_btn.type[0] == "tip"
          return [$btns.by_t(["tip",oposit(@my_lst_btn.type[1]),oposit(@my_lst_btn.type[2])])]
        else
          @strategy = 2
          if $last_btn.type[1] != nil
            return [$btns.by_t(["tip",oposit($last_btn.type[1]),@my_lst_btn.type[2]])]
          else
            return [$btns.by_t(["tip",@my_lst_btn.type[1],oposit($last_btn.type[2])])]
          end
        end
      end  
    end
    
    if $num_moves == 4
      if @strategy == 1
        return valid.find_all{|btn| btn.type[0] == "tip"}[0]
      elsif @strategy == 2
        return [$btns.by_t(["center"])]
      end  
    end
    if $num_moves == 1
      if $last_btn.type[0] == "center"
        return valid.find_all{|btn| btn.type[0] == "tip"}
      else
        @strategy = [1,$last_btn] if $last_btn.type[0] == "side"
        return [$btns.by_t(["center"])]
      end
    end
    if $num_moves == 3
      if $last_btn.type[1] == oposit(@my_lst_btn.type[1]) and $last_btn.type[2] == 
      oposit(@my_lst_btn.type[2])
        return valid.find_all{|btn| btn.type[0] == "tip"}
      end
      if $btns.count{|btn| btn.type[0] == "tip" and btn.label_widget.markup == 
        @o_markup} == 2
        return valid.find_all{|btn| btn.type[0] == "side"}
      end
      if @strategy[0] == 1
        first_btn = @strategy[1]
        if (first_btn.type[1].nil?) ^ ($last_btn.type[1].nil?)
          if first_btn.type[1].nil
            return [$btns.by_t(["tip",$last_btn.type[1],first_btn.type[2]])]
          else
            return [$btns.by_t(["tip",first_btn.type[1],$last_btn.type[2]])]
          end
        else
          return [valid.find_all{|btn| btn.type[0] == "tip"}]
        end  
      end  
    end
    puts "RETURN VALID"
    return valid
  end  
  
  # [Receive] <b>+String+:</b> Type of care, if type == "previne", will prevent a defeat, else, will hold the final victory move.
  # [Return] <b>+Object+:</b> A button
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
      null_btn = check_2_btns($btns.by_c(x + 1,y),$btns.by_c(x + 2,y),compare_markup)
    elsif x == 1
      null_btn = check_2_btns($btns.by_c(x + 1,y),$btns.by_c(x - 1,y),compare_markup)
    else
      null_btn = check_2_btns($btns.by_c(x - 1,y),$btns.by_c(x - 2,y),compare_markup)
    end
    if null_btn.nil?
      if y == 0 
        null_btn = check_2_btns($btns.by_c(x,y + 1),$btns.by_c(x,y + 2),compare_markup)
      elsif y == 1
        null_btn = check_2_btns($btns.by_c(x,y + 1),$btns.by_c(x,y - 1),compare_markup)
      else
        null_btn = check_2_btns($btns.by_c(x,y - 1),$btns.by_c(x,y - 2),compare_markup)
      end  
    else
      return null_btn
    end  
    if null_btn.nil?
      if x == 0 and y == 0
        null_btn = check_2_btns($btns.by_c(1,1),$btns.by_c(2,2),compare_markup)
      elsif x == 2 and y == 2
        null_btn = check_2_btns($btns.by_c(0,0),$btns.by_c(1,1),compare_markup)
      elsif x == 2 and y == 0
        null_btn = check_2_btns($btns.by_c(1,1),$btns.by_c(0,2),compare_markup)
      elsif x == 0 and y == 2
        null_btn = check_2_btns($btns.by_c(1,1),$btns.by_c(2,0),compare_markup)
      elsif x == 1 and y == 1
        null_btn = check_2_btns($btns.by_c(0,0),$btns.by_c(2,2),compare_markup)
        return null_btn if null_btn != nil
        null_btn = check_2_btns($btns.by_c(2,0),$btns.by_c(0,2),compare_markup)
      end  
    end  
    return null_btn
  end

    # [Brief] Test if in 2 buttons, one is nil, and the other have the received mark
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <b>+Nil+</b>(if test result false) or <b>+Object:+</b> The Null button
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
      if null_btn.nil? or enemy_btn.nil?
        null_btn = nil
        enemy_btn = nil
      end  
    end
    return null_btn
  end     
  
end  



# The window that will apresent the board
class BoardWindow < Gtk::Window
  alias ori_init initialize
    # [Brief] Initial method, were the processes are divided in other methods
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def initialize
    ori_init
    init_vars
    create_texts
    declare_signals
    agroup_components
  end
    # [Brief] Initializes variables
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def init_vars
    self.resize(200,250)
    @new_btn = Gtk::Button.new("")
    @default_size_btn = Gtk::Button.new("")
    @quit_btn = Gtk::Button.new("")
  end
    # [Brief] Initializes the string variables that will be apresented for the user
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>  
  def create_texts
    self.title = $idiom.tictactoe
    @new_btn.label = $idiom.new_game
    @quit_btn.label = $idiom.quit
    @default_size_btn.label = $idiom.default_size
  end  
    # [Brief] Declare the signals
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>  
  def declare_signals
    self.signal_connect("delete_event"){Gtk.main_quit}
    @new_btn.signal_connect("clicked"){
      $num_moves = -1
      $btns.each{|btn| btn.label_widget.set_markup($Null_markup)}
      $opts_window.show_all
    }
    @quit_btn.signal_connect("clicked"){Gtk.main_quit}
    @default_size_btn.signal_connect("clicked"){self.resize(200,250)}
  end  
    # [Brief] Agroup the components, making one englobe the other
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>    
  def agroup_components
    table = Gtk::Table.new(11,8)
    (0..8).each{|i|
      x = $btns[i].x
      y = $btns[i].y
      table.attach($btns[i],(x*2)+1,(x*2)+2,(y*2)+1,(y*2)+2)
    }
    (0..3).each{|i|
      table.attach(Gtk::VSeparator.new,i*2,(i*2)+1,0,8)
      table.attach(Gtk::HSeparator.new,0,8,i*2,(i*2)+1)   
    }
    table.attach(@new_btn,0,8,8,9)    
    table.attach(@default_size_btn,0,8,9,10)
    table.attach(@quit_btn,0,8,10,11)
    self.add(table)
  end  
end  



# Manages objects players
class Players < Array
  # <b>+Object+:</b> Represents the player who are playing.("act_p" means Active_Player)
  attr_accessor :act_p
  alias ori_init initialize
    # [Brief] Initial method, were the processes are divided in other methods
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def initialize(p1,p2)
    ori_init
    push p1
    push p2
    self[0].id = 0
    self[0].mark_markup = $X_markup
    self[1].id = 1
    self[1].mark_markup = $O_markup    
    @act_p = self[0]
  end
    # [Brief] Switch the active player.
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def switch_player
    @act_p = @act_p.id == 0 ? self[1] : self[0]
  end  
end  

# The board toolbutton class
class BoardToolButton < Gtk::ToolButton
  # <b>+Integer+:</b> Button x coordenate
  attr_reader :x
  # <b>+Integer+:</b> Button y coordenate
  attr_reader :y
  # [General] <b>+Array+:</b> Type of button.</br>
  # * <b>type[0]</b> = "center" or "tip" or "side";
  # * <b>type[1]</b> = "left" or "right" or nil;
  # * <b>type[2]</b> = "top" or "bottom" or nil.
  attr_reader :type
  alias ori_init initialize
    # [Brief] Initial method, were the processes are divided in other methods
    # [Receive] <html><list><li><b>+String+:</b> markup</li><li><b>+Integer+:</b> x</li><li><b>+Integer+:</b> y</li></list></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def initialize(markup,x,y)
    ori_init(nil,"")
    init_vars(markup,x,y)
    declare_signals
  end  
    # [Brief] Initializes variables
    # [Receive] <html><list><li><b>+String+:</b> markup</li><li><b>+Integer+:</b> x</li><li><b>+Integer+:</b> y</li></list></html>
    # [Return] <html><font color=red>Nothing</font></html>
  def init_vars(markup,x,y)
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
    self.label_widget = Gtk::Label.new.set_markup(markup)
  end   
    # [Brief] Declare the signals
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>  
  def declare_signals
    self.signal_connect("clicked"){|choiced|
      click_used = false
      if choiced.label_widget.markup == $Null_markup
        if $player.act_p.human?
          $last_btn = choiced
          $num_moves += 1
          choiced.label_widget.set_markup($player.act_p.mark_markup)
          $player.switch_player
          click_used = true
          check_victory
        end
        if !$player.act_p.human? and click_used and $num_moves < 8
          choiced = $player.act_p.turn
          $last_btn = choiced
          choiced.label_widget.set_markup($player.act_p.mark_markup)
          $player.switch_player
          check_victory
        end
      end
    }    
  end
  # [Brief] Puts the correct message in MessageWindow, and show her.
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>    
  def check_victory
    if victory?
      $msg_window.msg.set_text($idiom.player + ($player.act_p.mark_markup == $X_markup ? ' O ' : ' X ') + $idiom.win)
      $msg_window.show_all
    elsif $num_moves >= 8
      $msg_window.msg.set_text($idiom.draw)
      $msg_window.show_all
    end
  end    
  
  # [Brief] Tests if happened a victory move.
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def victory?
    x = $last_btn.x
    y = $last_btn.y
    vic = false
    if x == 0
      vic = check_2_btns($btns.by_c(x + 1,y),$btns.by_c(x + 2,y))
    elsif x == 1
      vic = check_2_btns($btns.by_c(x + 1,y),$btns.by_c(x - 1,y))
    else
      vic = check_2_btns($btns.by_c(x - 1,y),$btns.by_c(x - 2,y))
    end
    if vic == false
      if y == 0 
        vic = check_2_btns($btns.by_c(x,y + 1),$btns.by_c(x,y + 2))
      elsif y == 1
        vic = check_2_btns($btns.by_c(x,y + 1),$btns.by_c(x,y - 1))
      else
        vic = check_2_btns($btns.by_c(x,y - 1),$btns.by_c(x,y - 2))
      end  
    else
      return vic
    end  
    if vic == false
      if x == 0 and y == 0
        vic = check_2_btns($btns.by_c(1,1),$btns.by_c(2,2))
      elsif x == 2 and y == 2
        vic = check_2_btns($btns.by_c(0,0),$btns.by_c(1,1))
      elsif x == 2 and y == 0
        vic = check_2_btns($btns.by_c(1,1),$btns.by_c(0,2))
      elsif x == 0 and y == 2
        vic = check_2_btns($btns.by_c(1,1),$btns.by_c(2,0))
      elsif x == 1 and y == 1
        vic = check_2_btns($btns.by_c(0,0),$btns.by_c(2,2))
        return vic if vic != false
        vic = check_2_btns($btns.by_c(2,0),$btns.by_c(0,2))
      end  
    end  
    return vic
  end  

  # [Brief] Test if the tow received buttons have the some mark of the last marked.
  # [Receive] <html><list><li><b>+Object+:</b> A Button</li><li><b>+Object+:</b> A Button</li></list></html>
  # [Return] <b>+Boolean+</b>
  def check_2_btns(btn1,btn2)
    b1_mark = btn1.label_widget.markup
    b2_mark = btn2.label_widget.markup
    if b1_mark == b2_mark and b1_mark == $last_btn.label_widget.markup
      return true
    else
      return false
    end  
  end     
  # Recebe uma marca, e testa se a marca do botão é igual a recebida
  # [Brief] Test if the received markup are equal of the button markup
  # [Receive] <b>+String+</b> markup
  # [Return] <b>+Boolean+</b>  
  def marked?(mark_markup)
    return self.label_widget.markup == mark_markup
  end  
end  
# Array especial, para guardar Botões, que terá métodos especiais para o
# tratamento das mesmas
# Special array class to keep buttons, that have special methods for their tratament.
class BoardArrayBtns < Array
  # [Brief] Receive coordenates x and y, and return the button in this coordenates
  # [Receive] <html><list><li><b>+Integer+:</b> Coordenate x</li><li><b>+Integer+:</b> Coordenate y</li></list></html>
  # [Return] <b>+Object+:</b> Button
  def by_c(x,y)
    return self[x + y*3]
  end
  # [Brief] Receive a type, and return the button with this type
  # [Receive] <b>+String+:</b> type
  # [Return] <b>+Object+:</b> Button  
  def by_t(type)
    return self.find_all{|slot| slot.type == type}[0]
  end  
end
# Show the result of the game.
class MessageWindow < Gtk::Window
  # <b>+String+:</b> Represents the menssage that will be shown in the BoardWindow.
  attr_accessor :msg
  alias ori_init initialize
  # [Brief] Initial method, were the processes are divided in other methods
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def initialize
    ori_init("")
    init_vars
    declare_signals
    agroup_components
  end  
  # [Brief] Initializes variables
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def init_vars
    @msg = Gtk::Label.new("")
    self.resizable = false
    self.modal = true  
    self.window_position = Gtk::Window::POS_MOUSE    
  end
  # [Brief] Declare the signals
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>  
  def declare_signals
    self.signal_connect("delete_event"){
      $num_moves = -1
      $btns.each{|btn| btn.label_widget.set_markup($Null_markup)}
      $opts_window.show_all
      self.hide
    }
  end  
    # [Brief] Agroup the components, making one englobe the other
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>  
  def agroup_components
    self.add(@msg)
  end  
end  
# RadioButton of the OptionsWindow
class OptionsRadioButton < Gtk:: RadioButton
  alias ori_init initialize
  # <b>+Boolean+:</b> It's true if the button is selected.
  attr_writer :selected
  # [Brief] Initial method, were the processes are divided in other methods
  # [Receive] <b>+Object+:</b> A button, to in his group.
  # [Return] <html><font color=red>Nothing</font></html>
  def initialize(group)
    ori_init(group)
    init_vars
    declare_signals
  end
  # [Brief] Initializes variables
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def init_vars
    @selected = false
  end
  # [Brief] Agroup the components, making one englobe the other
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>  
  def declare_signals
    self.signal_connect("clicked"){
      self.group.each{|rd_btn| 
        if rd_btn.selected?
          rd_btn.selected = false
        end  
      }
      @selected = true
    }
  end  
  # [Brief] Return if the button is selected or not
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+Boolean+:</b> @selected
  def selected?
    return @selected
  end  
end  
# Window of options
class OptionsWindow < Gtk::Window
  alias ori_init initialize
  # [Brief] Initial method, were the processes are divided in other methods
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def initialize
    ori_init
    init_vars
    create_texts
    declare_signals
    agroup_components 
  end
  
  # [Brief] Initializes variables
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>
  def init_vars
    @hbox = Gtk::HBox.new
    @mode_vbox = Gtk::VBox.new
    @idiom_vbox = Gtk::VBox.new
    @geral_vbox = Gtk::VBox.new
    @new_btn = Gtk::Button.new("")
    @quit_btn = Gtk::Button.new("")
    self.resizable = false
    self.modal = true
    @mode_rdo = []
    (0..4).each{|i|
      @mode_rdo[i] = OptionsRadioButton.new(@mode_rdo[0])
    }
    @mode_rdo[0].selected = true
    @idiom_rdo = []
    (0..1).each{|i|
      @idiom_rdo[i] = Gtk::RadioButton.new(@idiom_rdo[0])
    }
  end
  # [Brief] Initializes the string variables that will be apresented for the user
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>   
  def create_texts
    self.title = $idiom.options
    @new_btn.label = $idiom.begin
    @quit_btn.label = $idiom.quit
    @idiom_rdo[0].label = $idiom.english
    @idiom_rdo[1].label = $idiom.portuguese 
    @mode_rdo[0].label = $idiom.player_player
    @mode_rdo[1].label = $idiom.player_very_easy
    @mode_rdo[2].label = $idiom.player_easy
    @mode_rdo[3].label = $idiom.player_medium
    @mode_rdo[4].label = $idiom.player_impossible    
  end  
  # [Brief] Agroup the components, making one englobe the other
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>  
  def declare_signals
    self.signal_connect("delete_event"){finish_commands}
    @new_btn.signal_connect("clicked"){finish_commands}
    @quit_btn.signal_connect("clicked"){Gtk.main_quit}
    @idiom_rdo[0].signal_connect("clicked"){
      change_idiom_to(:en)
      self.create_texts
    }
    @idiom_rdo[1].signal_connect("clicked"){
      change_idiom_to(:pt)
      self.create_texts
    }  
  end  
  # [Brief] Execute the commands that transfer the Options Window to the Board Window
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>    
  def finish_commands
    for i in 0..4
      if @mode_rdo[i].selected?
        $nivel = i - 1
        break
      end  
    end
    if $nivel == -1
      $player = Players.new(Player.new,Player.new)
    else
      $player = Players.new(Player.new,CPU.new)
    end
    if !$player.act_p.human?
      choiced = $player.act_p.turn
      choiced.label_widget.set_markup($player.act_p.mark_markup)
      $player.switch_player
    end
    self.hide
  end  
  # [Brief] Change the idiom of the game.
  # [Receive] <b>+String+:</b> A Idiom
  # [Return] <html><font color=red>Nothing</font></html> 
  def change_idiom_to(idiom)
    $idiom.idiom = idiom
    self.create_texts
    $board_window.create_texts
  end  
    # [Brief] Agroup the components, making one englobe the other
    # [Receive] <html><font color=red>Nothing</font></html>
    # [Return] <html><font color=red>Nothing</font></html>  
  def agroup_components
    (0..4).each{|i|
      @mode_vbox.pack_start(@mode_rdo[i])
    }
    (0..1).each{|i|
      @idiom_vbox.pack_start(@idiom_rdo[i])
    }
    @hbox.pack_start(@mode_vbox)
    @hbox.pack_start(@idiom_vbox)
    @geral_vbox.pack_start(@hbox)
    @geral_vbox.pack_start(@new_btn)
    @geral_vbox.pack_start(@quit_btn)
    self.add(@geral_vbox)
  end  
end  
# Controls the game's idiom.
class Idiom < Gtk::Button
  # <b>+String+:</b> The actual idiom of the game.
  attr_writer :idiom
  # [Brief] Initial method, that initialize's the idiom and create a hash variable for every phrase of the game
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <html><font color=red>Nothing</font></html>    
  def initialize
    @idiom = :en
    @new_game = {:en=>'New Game',:pt =>'Novo Jogo'}
    @begin = {:en=>'Begin',:pt =>'Começar'}
    @quit = {:en=>'Quit',:pt =>'Sair'}
    @default_size = {:en=>'Default Size',:pt =>'Tamanho Padrão'}
    @player_player = {:en=>'Player vs Player',:pt =>'Jogador vs Jogador'}
    @player_very_easy = {:en=>'Player vs CPU Very Easy',:pt =>'Jogador vs CPU Muito Fácil'}
    @player_easy = {:en=>'Player vs CPU Easy',:pt =>'Jogador vs CPU Fácil'}
    @player_medium = {:en=>'Player vs CPU Medium',:pt =>'Jogador vs CPU Médio'}
    @player_impossible = {:en=>'Player vs CPU Impossible',:pt =>'Jogador vs CPU Impossível'}
    @draw = {:en=>'Draw',:pt =>'Empate'}
    @win = {:en=>'Win',:pt =>'Venceu'}
    @lose = {:en=>'Lose',:pt =>'Perdeu'}
    @tictactoe = {:en=>'Tic Tac Toe',:pt =>'Jogo da Velha'}
    @options = {:en=>'Options',:pt =>'Opções'}
    @notification = {:en=>'Notification',:pt =>'Aviso'}
    @player = {:en=>'Player',:pt =>'Jogador'}
    @english = {:en=>'English',:pt =>'Inglês'}
    @portuguese = {:en=>'Portuguese',:pt =>'Português'}
  end
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def new_game
    return @new_game[@idiom]
  end
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def begin
    return @begin[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def quit
    return @quit[@idiom]
  end
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def default_size
    return @default_size[@idiom]
  end   
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player_player
    return @player_player[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player_very_easy
    return @player_very_easy[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player_easy
    return @player_easy[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player_medium
    return @player_medium[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player_impossible
    return @player_impossible[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def draw
    return @draw[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def win
    return @win[@idiom]
  end 
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def lose
    return @lose[@idiom]
  end 
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def tictactoe
    return @tictactoe[@idiom]
  end 
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def options
    return @options[@idiom]
  end   
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def player
    return @player[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def english
    return @english[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
  def portuguese
    return @portuguese[@idiom]
  end  
  # [Receive] <html><font color=red>Nothing</font></html>
  # [Return] <b>+String+:</b> the phrase in the actual idiom.  
end 
begin 
  #############################################################
  ## Declaração de Variáveis
  #############################################################
  $idiom = Idiom.new
  $nivel = -1
  $num_moves = -1
  $btns = BoardArrayBtns.new
  $Null_markup = "<span face='Lucida Console' size='50'> </span>"
  $X_markup = "<span face='Lucida Console' size='50'>X</span>"
  $O_markup = "<span face='Lucida Console' size='50'>O</span>"
  
  #############################################################
  ## Declaração de Componentes
  #############################################################
  ##################
  ## => BOTÕES <= ##
  ##################
  (0..8).each{|i|
    $btns[i] = BoardToolButton.new($Null_markup,i - Integer(i/3)*3,Integer(i/3))
  }
  
  ###################  
  ## => WINDOWS <= ##
  ###################
  $msg_window = MessageWindow.new 
  $opts_window = OptionsWindow.new
  $board_window = BoardWindow.new  

  #############################################################
  ## Demonstração dos Componentes
  #############################################################
  $board_window.show_all
  $opts_window.show_all
  #############################################################
  ## Passa Controle Para Gtk
  #############################################################
  Gtk.main
end  