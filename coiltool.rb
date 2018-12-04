require 'Prawn'
class Plot
  include Prawn::View
  
  def initialize
    @page_width = 550
    @page_height = 770
    @bottom_margin = 300
    @top_margin = 100
    @left_margin = 30
    @min_x = Math.log10(1000)-2
    @max_x = Math.log10(19000)-2
    @start_y = @page_height - (@bottom_margin + @top_margin)
    @plot_height = @start_y
    @end_y = @page_height - @top_margin 
    @x_per_hz = (@page_width-@left_margin)/(@max_x-@min_x)
    @y_per_db = (@end_y-@start_y) / 40 #  +10db to -30db  = 40db total
    @no_plots = 0
    render_file 'out.pdf'
    bounding_box([0,@page_height],:width=>@page_width,:height=>@page_height) do
      line_width(0.15)
      dash([0.5,4],:phase=>1)
      font_size(6)
      xaxis_line(1000)
      xaxis_line(2000)
      xaxis_line(3000)
      xaxis_line(4000)
      xaxis_line(5000)
      xaxis_line(6000)
      xaxis_line(7000)
      xaxis_line(8000)
      xaxis_line(9000)
      xaxis_line(10000)
      xaxis_line(20000)
      yaxis_line(30)
      yaxis_line(20)
      yaxis_line(10)
      yaxis_line(0)
      yaxis_line(-10)
      
      
      stroke
      
      undash
      line [@left_margin,@start_y],[@page_width+@left_margin,@start_y]
      line [@left_margin,@end_y],[@page_width+@left_margin,@end_y]
      stroke
      
      draw_text 'Guitar Pickup Analyzer', :at=>[@left_margin,730], :size=>16
    end
  end
  def plot_file(fname,color)   
    f = File.open(fname)
    maxdb = 0.0
    maxhz = 0.0
    self.stroke_color = color
    self.fill_color = color
    bounding_box([0,@page_height],:width=>@page_width,:height=>@page_height) do
      f.gets  # first line is headers, skip
      spoint = nil
      while(l = f.gets())
        p = l.split(',')
        hz = p[0].to_f
        db = p[1].to_f
        y = plot_point_y(db) + @start_y
        x = plot_point_x(hz) + @left_margin
        unless spoint
          spoint = [x,y]  # save the first 'starting' point
        else
          line spoint, [x,y]
          if db > maxdb
            maxdb = db
            maxhz = hz
          end
          spoint = [x,y]
        end
      end
    end
    stroke
    draw_text("#{fname}, res freq = #{maxhz.to_i}", :at=>[@left_margin,@start_y-(100 + (18 * @no_plots))], :color=>color, :size=>14)
    stroke
    @no_plots += 1
  end 
  def xaxis_line(hz)
    x = plot_point_x(hz) + @left_margin
    line [x , @start_y],[x,@end_y]
    if hz < 1000
      draw_text "#{hz}" ,:at=>[x-5,@start_y - 8], :size=>6
    else
      draw_text "#{hz/1000}K" , :at=>[x-2,@start_y - 8], :size=>6
    end
  end
  def yaxis_line(db)
    y = plot_point_y(db) + @start_y
    line [@left_margin,y],[@page_width+@left_margin,y]
    draw_text "#{db} db", :at=>[10,y]
  end
  def plot_point_y(val)
    (val) * @y_per_db 
  end
  def plot_point_x(val)
    (((Math.log10(val)-2)-@min_x)) * @x_per_hz 
  end
end

@color_array = ['000000','FF0000','22FF11','2222FF']
aplot = Plot.new
ai=0
ARGV.each do |a|
  aplot.plot_file("#{a}.csv",@color_array[ai])
  ai += 1
end
aplot.save_as('out.pdf')
