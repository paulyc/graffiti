
{client{

  let draw ctx base_size (width, height) (color, size, (x1, y1), (x2, y2)) =
    ctx##strokeStyle <- (Js.string color);
    ctx##lineWidth <- (size *. base_size);
    ctx##beginPath();
    ctx##moveTo(x1 *. width, y1 *. height);
    ctx##lineTo(x2 *. width, y2 *. height);
    ctx##stroke()

  (** launch check to remove header and get it's height **)
  let get_header_height () =
    if (Client_mobile.remove_header_mobile ())
    then 0
    else let dom_header =
           Eliom_content.Html5.To_dom.of_div %Server_html.header_elt
         in dom_header##clientHeight

  (** Calcul and set size of canvas **)
  let init () =

    (*** Init data ***)
    let size = Client_tools.get_size () in
    let dom_canvas =
      Eliom_content.Html5.To_dom.of_canvas %Server_html.canvas_elt
    in
    let margin = 3 in
    let width = (fst size) - (margin * 2) in
    let height = (snd size) - (margin * 4) - (get_header_height ()) in

    (*** Tool ***)
    (** if max = true, set max size, else, set min size **)
    let set_size max value =
      if ((width <= height && max) ||
             width > height && not max)
      then width, value
      else value, height
    in

    (*** First calcul ***)
    let window_orientation, min =
      if (width <= height)
      then Client_tools.Portrait, width
      else Client_tools.Landscape, height
    in

    let max = Shared_tools.get_max_resolution min in

    (*** Check result ***)
    (* If max value is out of window, it is wrong *)
    let good_result =
      if (width <= height)
      then (height >= max)
      else (width >= max)
    in

    (* Try the other way if result is not a good_result *)
    let width', height' = if (not good_result)
      then (
        let max = if (width > height)
          then width
          else height
        in
        let min = Shared_tools.get_min_resolution max in

        (* Second way set *)
        set_size false min )

      (* First way set *)
      else (set_size true max)
    in

    (* Init canvas *)
    dom_canvas##width <- width';
    dom_canvas##height <- height';

    (* return result *)
    (window_orientation, (width', height'))

}}
