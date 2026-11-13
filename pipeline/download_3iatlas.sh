#! /bin/sh
cat <<EOF
************************************************
*
*    Date: Wed Jan 14 08:34:30 PST 2026
*
*    Script to download SPHEREx data from IRSA of 3I/ATLAS
*
*    The script below defines a subroutine to download the files
*
************************************************

EOF
    download_file() {

      href="$1"
      targetDir="$2"
      baseFileName="$3"
      suffix="$4"

      startDir=$(pwd)

      # create temp dir
      tmpDir=$(mktemp -d)
      cd "$tmpDir" || return 1

      echo ">> downloading ${href} ..."
      cmd="wget --content-disposition --tries=5 --waitretry=5 --retry-connrefused --retry-on-http-error=502,503,504"
      $cmd "$href" || {
        echo ">> ERROR: failed to download ${href}"
        cd "$startDir"
        rm -rf "$tmpDir"
        return 1
      }

      # get most recently modified file
      downloadedFile=$(ls -t | head -n 1)

      # determine filename
      if [ -n "$baseFileName" ]; then
        ext="${baseFileName##*.}"
        name="${baseFileName%.*}"
      else
        ext="${downloadedFile##*.}"
        name="${downloadedFile%.*}"
      fi

      # Apply suffix, if available
      finalName="$name"
      [ -n "$suffix" ] && finalName="${finalName}-$suffix"
      finalFile="${finalName}.${ext}"

      # create target dir in current directory
      if [ -n "$targetDir" ]; then
        destDir="$startDir/$targetDir"
      else
        destDir="$startDir"
      fi
      mkdir -p "$destDir"

      # resolve naming conflicts
      destPath="$destDir/$finalFile"
      count=1
      while [ -e "$destPath" ]; do
        destPath="$destDir/${finalName} (${count}).${ext}"
        count=$((count + 1))
      done

      # move file to main directory and cleanup
      mv "$downloadedFile" "$destPath"
      echo ">> Saved as $destPath"



      cd "$startDir"
      rm -rf "$tmpDir"
    }

download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/6/level2_2025W31_2A_0156_1D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/3/level2_2025W31_2A_0156_1D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/3/level2_2025W31_2A_0156_2D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/6/level2_2025W31_2A_0156_2D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/6/level2_2025W31_2A_0156_3D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/3/level2_2025W31_2A_0156_3D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/3/level2_2025W31_2A_0156_4D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/6/level2_2025W31_2A_0156_4D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/2/level2_2025W31_2A_0219_1D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/5/level2_2025W31_2A_0219_1D5_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/5/level2_2025W31_2A_0219_2D5_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/2/level2_2025W31_2A_0219_2D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/2/level2_2025W31_2A_0219_3D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W31_2A/l2b-v20-2025-264/5/level2_2025W31_2A_0219_3D5_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0612_1D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0612_1D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0612_2D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0612_2D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0637_1D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0637_1D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0637_2D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0637_2D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0637_3D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0637_3D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0637_4D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0637_4D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0662_1D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0662_1D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0662_2D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0662_2D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0662_3D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0662_3D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/3/level2_2025W32_1A_0662_4D3_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_1A/l2b-v20-2025-264/6/level2_2025W32_1A_0662_4D6_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0017_1D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0017_1D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0017_2D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0017_2D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0017_3D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0017_3D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0017_4D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0017_4D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0091_2D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0091_2D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0091_3D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0091_3D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0091_4D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0091_4D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0189_1D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0189_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0189_2D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0189_2D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0189_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0189_3D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0189_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0189_4D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0201_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0201_1D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0201_2D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0201_2D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0201_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0201_3D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0201_4D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0201_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/5/level2_2025W32_2D_0213_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-264/2/level2_2025W32_2D_0213_4D2_spx_l2b-v20-2025-264.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0224_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0224_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0224_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0224_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0343_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0343_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0343_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0343_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0343_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0343_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0343_4D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0343_4D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0355_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0355_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0355_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0355_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/4/level2_2025W32_2D_0355_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/1/level2_2025W32_2D_0355_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0426_4D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0426_4D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/3/level2_2025W32_2D_0480_4D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W32_2D/l2b-v20-2025-265/6/level2_2025W32_2D_0480_4D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0010_3D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0010_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0010_4D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0010_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0020_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0020_1D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0020_2D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0020_2D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0020_3D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0020_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0020_4D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0020_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0049_1D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0049_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0049_2D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0049_2D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0049_3D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0049_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0049_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0049_4D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0088_4D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0134_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0134_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0134_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0134_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0134_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0134_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0183_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0183_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0183_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0183_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0183_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0183_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0183_4D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0183_4D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0399_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0399_1D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0399_2D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0399_2D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0399_3D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0399_3D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0399_4D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0399_4D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0447_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0447_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0447_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0447_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/3/level2_2025W33_1B_0499_1D3_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/6/level2_2025W33_1B_0499_1D6_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0576_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0576_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0576_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0576_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0576_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0576_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0576_4D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0576_4D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/5/level2_2025W33_1B_0599_1D5_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/2/level2_2025W33_1B_0599_1D2_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0642_1D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0642_1D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0642_2D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0642_2D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0642_3D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0642_3D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/1/level2_2025W33_1B_0642_4D1_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_1B/l2b-v20-2025-265/4/level2_2025W33_1B_0642_4D4_spx_l2b-v20-2025-265.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-266/4/level2_2025W33_2C_0073_1D4_spx_l2b-v20-2025-266.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-267/1/level2_2025W33_2C_0073_1D1_spx_l2b-v20-2025-267.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-266/4/level2_2025W33_2C_0220_1D4_spx_l2b-v20-2025-266.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-267/1/level2_2025W33_2C_0220_1D1_spx_l2b-v20-2025-267.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-267/1/level2_2025W33_2C_0255_1D1_spx_l2b-v20-2025-267.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W33_2C/l2b-v20-2025-266/4/level2_2025W33_2C_0255_1D4_spx_l2b-v20-2025-266.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0002_1D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0002_1D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0002_2D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0002_2D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0002_3D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0002_3D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0002_4D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0002_4D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0021_1D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0021_1D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0021_2D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0021_2D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0021_3D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0021_3D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0021_4D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0021_4D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0038_1D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0038_1D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0038_2D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0038_2D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0038_3D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0038_3D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0038_4D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0038_4D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0105_2D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0106_1D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0106_1D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0106_2D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0106_2D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0106_3D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0106_3D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/4/level2_2025W50_1A_0106_4D4_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-342/1/level2_2025W50_1A_0106_4D1_spx_l2b-v20-2025-342.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/4/level2_2025W50_1A_0120_1D4_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/1/level2_2025W50_1A_0120_1D1_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/5/level2_2025W50_1A_0348_1D5_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/2/level2_2025W50_1A_0348_1D2_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/2/level2_2025W50_1A_0348_2D2_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/5/level2_2025W50_1A_0348_2D5_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/2/level2_2025W50_1A_0348_3D2_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/5/level2_2025W50_1A_0348_3D5_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/5/level2_2025W50_1A_0348_4D5_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_1A/l2b-v20-2025-343/2/level2_2025W50_1A_0348_4D2_spx_l2b-v20-2025-343.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0685_1D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0685_1D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0685_2D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0685_2D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0685_3D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0685_3D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0685_4D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0685_4D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0698_1D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0698_1D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0698_2D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0698_2D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0698_3D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0698_3D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0698_4D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0698_4D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0712_1D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0712_1D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0712_2D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0712_2D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0712_3D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0712_3D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0712_4D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0712_4D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0741_1D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0741_2D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0741_2D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0741_3D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0741_3D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0741_4D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0741_4D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0755_1D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0755_2D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0755_2D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0755_3D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0755_3D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0755_4D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0755_4D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0797_1D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0797_1D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0797_2D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0797_2D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0797_3D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0797_4D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0797_4D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0813_1D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0813_1D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0813_2D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0813_2D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0813_3D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0813_4D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/6/level2_2025W50_2A_0813_4D6_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/2/level2_2025W50_2A_0827_1D2_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/5/level2_2025W50_2A_0827_1D5_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
download_file 'https://irsa.ipac.caltech.edu/ibe/data/spherex/qr2/level2/2025W50_2A/l2b-v20-2025-349/3/level2_2025W50_2A_0854_1D3_spx_l2b-v20-2025-349.fits' 'SPHERExLVFSurveyData3IATLAS' '' ''
