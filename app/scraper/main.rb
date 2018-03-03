require_relative 'classes/scraped'
require_relative 'classes/scraping_authenticate'
require_relative 'classes/scraping_pomelo'
require_relative 'classes/scraping_unespacio'
require_relative 'classes/scraping_authenticate'
require_relative 'modules/console_view_module'
require_relative 'modules/file_module'
require 'date'

sp = ScrapingPomelo.new
su = ScrapingUnespacio.new
sl = ScrapingAuthenticate.new

if !su.load_rooms
  puts "Necesitamos que haga login para hacer fetch de la informacion."
  ConsoleViewModule.login(sl, "unespacio")
  puts "\nIniciando porfavor espere, esto puede tomar un momento..."
  su.create_rooms
end

begin 
  option = ConsoleViewModule.menu(
    "Bienvenido al script de Matriz de Conflicto y Unespacio:",
    "Ver horario de un estudiante.",
    "Agregar horario de un estudiante a la Matriz de conflicto.",
    "Mostrar la Matriz de conflicto.",
    "Guardar la Matriz de conflicto (.json)",
    "Renderizar .json de una Matriz de conflicto.",
    "Ver el horario de un salon todo el dia",
    "Reservar cubiculo.",
    "Cancelar reserva.",
    "Reservar cubiculo para la Matriz de Conlicto."
  )  
  case option
    when 1
      ConsoleViewModule.login(sl, "pomelo")
      pp sp.student_info()
      puts ""
    when 2
      ConsoleViewModule.login(sl, "pomelo")
      pp sp.student_info(true)
      puts "\nEstudiante añadido!"
    when 3
      puts ""
      pp sp.conflict_matrix
    when 4
      if FileModule.create_json(sp.conflict_matrix) then puts "Creacion de Json satisfactoria!" else puts "File Error!" end
    when 5
      pp FileModule.render_json(ConsoleViewModule.get_int("Numero de la MC: "))  
    when 6 
      ConsoleViewModule.login(sl, "unespacio")
      date = ConsoleViewModule.get_date("Ingrese la fecha a buscar: ")
      p su.search_room_schedule(
        ConsoleViewModule.message_from_0(
          "Selecione alguno de los siguientes cubiculos para reservar: ",
          su.rooms_names
          ), 
        date
      )
    when 7
      ConsoleViewModule.login(sl, "unespacio")
      status = su.reserve_room(
        ConsoleViewModule.message_from_0(
          "Selecione alguno de los siguientes cubiculos para reservar: ",
          su.search_room_to_reserve(
            ConsoleViewModule.get_date("Ingrese la fecha a reservar: "),
            ConsoleViewModule.get_hour_range("El rango maximo puede tener una diferencia de 2 horas\nEl rango debe ser multiplo de media hora\nIngrese el rango de hora : ")
          )
        )
      )
      if status then puts "Se ha reservado el cubiculo satisfactoriamente!" else puts "No se ha podido reservar el cubiculo." end
    when 8
      ConsoleViewModule.login(sl, "unespacio")
      status = su.cancel_booking(
        ConsoleViewModule.menu_from_0(
          "Selecione alguna de las reservas para cancelarla: ",
          su.search_bookings
        )
      )
     if status then puts "Se ha cancelado la reserva satisfactoriamente!" else puts "No se ha podido cancelar la reserva del cubiculo." end 
    when 9
      pp 
      if !sp.conflict_matrix_is_clean?
        status = false
        date = ConsoleViewModule.get_date("Ingrese la fecha a buscar: ")
        range = ConsoleViewModule.message_from_0("Selecione alguna de las siguientes horas libres comunes para reservar: ", sp.free_conflict_hours(date))
        intervals = su.intervals_to_reserve(ConsoleViewModule.get_hour_range_between("\nEl rango debe ser multiplo de media hora\nIngrese el rango de hora dentro de #{range} a reservar: ", range))
        status = su.reserve_conflict_matrix(
          ConsoleViewModule.message_from_0(
            "Selecione alguno de los siguientes cubiculos para reservar: ", 
            su.search_room_to_conflict_matrix(date, range, sl)
            ),
          date,
          intervals,
          sl        
        )
      else 
        puts "Primero ingrese estudiantes a la matriz de conflicto. Con la opcion numero 2."
      end
     if status then puts "Se ha reservado el cubiculo satisfactoriamente!" else puts "No se ha podido reservar el cubiculo." end
  end
end until option == 0
