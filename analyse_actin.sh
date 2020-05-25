#! /bin/bash
# Usage: analyse_actin.sh <image_list>

# User settings ----------------------------------------------------------------
MAX_SLICES=20
PLOT_WIDTH=800
PLOT_HEIGHT=600
PLOT_POINTSIZE=24
MAX_PIXEL_INTENSITY=255
TIME_INTERVAL_SECONDS=2.5
PLOT_XLAB="Time interval (s)"
PLOT_YLAB="Fluorescence intensity (AU)"
DELETE_GENERATED_SCRIPTS="no"
#-------------------------------------------------------------------------------

# Generate a valid ImageJ macro from the template and user-defined values.
sed "s/<max_slices>/$MAX_SLICES/g\
  " extract_slices.template \
> extract_slices.ijm

# Generate a valid R script from the template and user-defined values.
# Format is "s(ubstitute)/pattern/replacement/g(eneral)".
sed "s/<plot_filename>/$PLOT_FILENAME/g; \
     s/<plot_width>/$PLOT_WIDTH/g; \
     s/<plot_height>/$PLOT_HEIGHT/g; \
     s/<plot_pointsize>/$PLOT_POINTSIZE/g; \
     s/<plot_xlab>/$PLOT_XLAB/g; \
     s/<max_pixel>/$MAX_PIXEL_INTENSITY/g; \
     s/<seconds>/$TIME_INTERVAL_SECONDS/g; \
     s/<plot_ylab>/$PLOT_YLAB/g" generate_diffmaps.template \
> generate_diffmaps.R

# Tell that something is wrong if there is no argument.
# Otherwise, analyse all files one by one.
if [[ "$#" -lt 1 ]]; then
  echo "Usage: analyse_actin.sh <image_list>"
else
  for FILE in "$@"; do
    echo "> Analyzing actin dynamics of $FILE"
    echo "    Extracting slices and matrices"
    DATA="$(imagej -b extract_slices.ijm "$FILE" | tail -n 1)"
    WIDTH="$(echo "$DATA" | awk '{print $1}')"
    HEIGHT="$(echo "$DATA" | awk '{print $2}')"
    FOLDER="$(echo "$DATA" | awk '{print $3}')"
    PLOT="$(basename "$FILE" .tif)_plot.jpg"
    echo "    Generating difference maps (W = $WIDTH, H = $HEIGHT, '$FOLDER')"
    Rscript --vanilla generate_diffmaps.R "$FOLDER" "$WIDTH" "$HEIGHT" "$PLOT"
  done 
fi

# Should we keep the generated scripts (e. g. for manual use)?
if [[ $DELETE_GENERATED_SCRIPTS == "yes" ]]; then 
  rm extract_slices.ijm generate_diffmaps.R
fi
