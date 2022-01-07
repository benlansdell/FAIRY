##Run FAIRY

#Prepare data directories as needed

RESOLUTION=40x
SITE=all
DATA_ROOT=/mnt/storage2/COMET/FAIRY_DATASETS_ALL_TUMORS/
STEP_SIZE=2024
PATCH_SIZE=2024

#Make patches
#Run for each diagnosis

for DIAGNOSIS in RMS_A RMS_E RMS_S EWS MRT NB OS
do
    echo "Making patches and mosaic for $DIAGNOSIS slides"
    python create_patches_fp.py --source $DATA_ROOT/WSI/$SITE/$DIAGNOSIS/$RESOLUTION --step_size $STEP_SIZE \
                --patch_size $PATCH_SIZE --seg --patch \
                --save_dir $DATA_ROOT/PATCHES/$SITE/$DIAGNOSIS/$RESOLUTION

    #Make mosaic
    python extract_mosaic.py --slide_data_path $DATA_ROOT/WSI/$SITE/$DIAGNOSIS/$RESOLUTION \
                --slide_patch_path $DATA_ROOT/PATCHES/$SITE/$DIAGNOSIS/$RESOLUTION/patches/ \
                --save_path $DATA_ROOT/MOSAICS/$SITE/$DIAGNOSIS/$RESOLUTION

done

python artifacts_removal.py --site_slide_path $DATA_ROOT/WSI/$SITE --site_mosaic_path $DATA_ROOT/MOSAICS/$SITE

#Make index
CUDA_VISIBLE_DEVICES=1 python build_index.py --site $SITE --mosaic_path $DATA_ROOT/MOSAICS/ --slide_path $DATA_ROOT/WSI

#Perform leave-one-out search
#Need to update a few things in this code
python main_search.py --site $SITE --db_index_path ./DATABASES/$SITE/index_tree/veb.pkl --index_meta_path ./DATABASES/$SITE/index_meta/meta.pkl \
            --slide_path $DATA_ROOT/WSI 


#Example run
#python main_search.py --site all --db_index_path ./DATABASES/all/index_tree/veb.pkl --index_meta_path ./DATABASES/all/index_meta/meta.pkl \
#            --slide_path /mnt/storage/COMET/FAIRY_DATASETS/WSI 

#python create_patches_fp.py --source /mnt/storage2/COMET/FAIRY_DATASETS_ALL_TUMORS/WSI/all/OS/40x --step_size 1024 \
#                --patch_size 1024 --seg --patch \
#                --save_dir /mnt/storage2/COMET/FAIRY_DATASETS_ALL_TUMORS/PATCHES/all/OS/40x