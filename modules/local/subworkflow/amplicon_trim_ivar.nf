/*
 * iVar trim, sort, index BAM file and run samtools stats, flagstat and idxstats
 */

params.ivar_trim_options = [:]
params.samtools_options  = [:]

include { IVAR_TRIM         } from '../process/ivar_trim'                        addParams( options: params.ivar_trim_options )
include { SAMTOOLS_INDEX    } from '../../nf-core/software/samtools/index/main'  addParams( options: params.samtools_options  )
include { BAM_SORT_SAMTOOLS } from '../../nf-core/subworkflow/bam_sort_samtools' addParams( options: params.samtools_options  )

workflow AMPLICON_TRIM_IVAR {
    take:
    bam // channel: [ val(meta), [ bam ], [bai] ]
    bed // path   : bed

    main:
    /*
     * iVar trim amplicons
     */
    IVAR_TRIM ( bam, bed )

    /*
     * Sort, index BAM file and run samtools stats, flagstat and idxstats
     */
    BAM_SORT_SAMTOOLS ( IVAR_TRIM.out.bam )
    
    emit:
    orig_bam         = IVAR_TRIM.out.bam              // channel: [ val(meta), bam   ]
    log_out          = IVAR_TRIM.out.log_out          // channel: [ val(meta), log   ]
    ivar_version     = IVAR_TRIM.out.version          //    path: *.version.txt

    bam              = BAM_SORT_SAMTOOLS.out.bam      // channel: [ val(meta), [ bam ] ]
    bai              = BAM_SORT_SAMTOOLS.out.bai      // channel: [ val(meta), [ bai ] ]
    stats            = BAM_SORT_SAMTOOLS.out.stats    // channel: [ val(meta), [ stats ] ]
    flagstat         = BAM_SORT_SAMTOOLS.out.flagstat // channel: [ val(meta), [ flagstat ] ]
    idxstats         = BAM_SORT_SAMTOOLS.out.idxstats // channel: [ val(meta), [ idxstats ] ]
    samtools_version = BAM_SORT_SAMTOOLS.out.version  //    path: *.version.txt
}
