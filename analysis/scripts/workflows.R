#flowchart of Random Forest Algorithm
mermaid("graph TB
        A((dataset))-->B[Decision Tree 1]
        A((dataset))-->C[Decision Tree 2]
        A((dataset))-->D[Decision Tree n]
        B[Decision Tree 1]-.->|Prediction 1|E[majority voting/averaging]
        C[Decision Tree 2]-.->|Prediction 2|E[majority voting/averaging]
        D[Decision Tree n]-.->|Prediction n|E[majority voting/averaging]
        E[majority voting/averaging]-->F[final prediction]

        style A fill:#FFF, stroke:#333, stroke-width:3px
        style B fill:#5F9EA0, stroke:#2F4F4F, stroke-width:3px
        style C fill:#5F9EA0, stroke:#2F4F4F, stroke-width:3px
        style D fill:#5F9EA0, stroke:#2F4F4F, stroke-width:3px
        style E fill:#d5f4e6, stroke:#618685, stroke-width:2px
        style F fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5")

#flowchart of Automated Analysis Methods
DiagrammeR("graph TB
            A(Automated Analysis in Archaeological Remote Sensing)==>B[Template Matching-based]
            A(Automated Analysis in Archaeological Remote Sensing)==>C[Geometric knowledge-based]
            A(Automated Analysis in Archaeological Remote Sensing)==>D[GeOBIA-based]
            A(Automated Analysis in Archaeological Remote Sensing)==>E[Machine Learning-based]
            B[Template Matching-based]-.->F(Rigid Template Matching)
            B[Template Matching-based]-.->G(Deformable Template Matching)
            C[Geometric knowledge-based]-.->H(Geometric Knowledge)
            C[Geometric knowledge-based]-.->I(Context Knowledge)
            D[GeOBIA-based]-.->J(Image Segmentation)
            J(Image Segmentation)-.->K(Object Classification)
            E[Machine Learning-based]-.->L(Feature Extraction)
            L(Feature Extraction)-.->M(Feature fusion)
            M(Feature fusion)-.->N(Classifier training)
            E[Machine Learning-based]-->O[Deep Learning]
            O[Deep Learning]-.->P(Network Architecture)
            P(Network Architecture)-.->Q(Classifier)

            style A fill:#d5f4e6, stroke:#618685, stroke-width:5px
            style B fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style C fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style D fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style E fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style F fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style G fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style H fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style I fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style J fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style K fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style L fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style M fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style N fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style O fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style P fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style Q fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5")
#or
DiagrammeR("graph LR
            A[DTM/MSTPI]->>B[Template Matching-based]
            B[Template Matching-based]-.->F(Rigid Template Matching)
            B[Template Matching-based]-.->G(Deformable Template Matching)
            C[Geometric knowledge-based]-.->H(Geometric Knowledge)
            C[Geometric knowledge-based]-.->I(Context Knowledge)
            D[GeOBIA-based]-.->J(Image Segmentation)
            J(Image Segmentation)-.->K(Object Classification)
            E[Machine Learning-based]-.->L(Feature Extraction)
            L(Feature Extraction)-.->M(Feature fusion)
            M(Feature fusion)-.->N(Classifier training)
            E[Machine Learning-based]-->O[Deep Learning]
            O[Deep Learning]-.->P(Network Architecture)
            P(Network Architecture)-.->Q(Classifier)

            style A fill:#d5f4e6, stroke:#618685, stroke-width:5px
            style B fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style C fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style D fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style E fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style F fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style G fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style H fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style I fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style J fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style K fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style L fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style M fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style N fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style O fill:#d5f4e6, stroke:#618685, stroke-width:2px
            style P fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5
            style Q fill:#d5f4e6, stroke:#618685, stroke-width:2px, stroke-dasharray: 5 5")

#general automated analysis workflow
mermaid("
sequenceDiagram
  i Data PreProcessing->>ii Data Preparation: LAS/LAZ, .xyz file
  alt choose Data Preparation method/s
    ii Data Preparation->>iii Data Analysis: ii-i visualisation methods
    ii Data Preparation->>iii Data Analysis: ii-ii textural analysis
    ii Data Preparation->>iii Data Analysis: ii-iii morphometric analysis
    ii Data Preparation->>iii Data Analysis: ii-iv morphometric enhancement
    ii Data Preparation->>iii Data Analysis: ii-v morphometric extraction
  else choose Data Analysis method/s
    iii Data Analysis->>iv Data interpretation/verification: iii-i Geometric-knowledge-based
    iii Data Analysis->>iv Data interpretation/verification: iii-ii GeOBIA
    iii Data Analysis->>iv Data interpretation/verification: iii-iii Machine Learning
  end
")

#workflow DTM generation
mermaid("
sequenceDiagram
  LAS/LAZ files ->>Ground Point Re/Classification: lidR::readLAS/readLAScatalog
  Note right of LAS/LAZ files: select attributes, filter class, lidR::lascheck
  alt choose Point Cloud Re/Classification Algorithm
    LAS/LAZ files->>Spatial Interpolation: A) Ground Classification (select = xyzirnc + filter = keep_class_2)
    Note right of Ground Point Re/Classification: lidR:: classify_ground
    LAS/LAZ files ->>Ground Point Re/Classification: select = xyzirnc
    Ground Point Re/Classification->>Spatial Interpolation: B) Progressive Morphological Filter (PMF)
    Ground Point Re/Classification->>Spatial Interpolation: C) Cloth Simulation Function (CSF)
  else choose Spatial Interpolation Algorithm
    Note right of Spatial Interpolation: lidR:: grid_terrain
    Spatial Interpolation->> DTM:Triangulated Irregular Networks (TIN)
    Spatial Interpolation->> DTM:Inverse Distance Weighing (IDW)
  end
")

#Workflow Freeland et al 2016
mermaid("
sequenceDiagram
  DTM->>fDTM: mean filter
  fDTM->>ifDTM: invert raster
  ifDTM->>pf ifDTM: fill pits
  Note right of ifDTM: Wang & Liu 2006
  pf ifDTM->>diff ifDTM: ifDTM-pf ifDTM
  Note left of possible earthworks: optional filtering of diff ifDTM before morphometric rules
  diff ifDTM->> possible earthworks: morphometric rules
")

#Workflow Davis et al 2019
mermaid("
sequenceDiagram
  DTM->>iDTM: invert raster
  Note left of deprMaps: Monte Carlo Simulation to map depressions
  iDTM->>deprMaps: SDA Whitebox GAT - comparision of results
  deprMaps->>fdeprMaps: filter to size
  fdeprMaps->>possible mound shellrings: comparsion to lu maps
")

#Workflow Rom et al 2020
mermaid("
sequenceDiagram
  DTM->>fDTM: lowpass filter
  fDTM->>ifDTM: invert raster
  ifDTM->>pf ifDTM: fill pits
  Note right of ifDTM: Wang & Liu 2006
  pf ifDTM->>diff ifDTM: ifDTM-pf ifDTM
  diff ifDTM->> thresh diff ifDTM: thresholds
  Note right of diff ifDTM: min height, max area
  thresh diff ifDTM->>possible tell mounds: invert raster
")

#workflow DTM generation
mermaid("
sequenceDiagram
  LAS/LAZ files ->>Ground Point Re/Classification: lidR::readLAS/readLAScatalog
  Note right of LAS/LAZ files: select attributes, filter class, lidR::lascheck
  alt choose Point Cloud Re/Classification Algorithm
    LAS/LAZ files->>Spatial Interpolation: A) Ground Classification (select = xyzirnc + filter = keep_class_2)
    Note right of Ground Point Re/Classification: lidR:: classify_ground
    LAS/LAZ files ->>Ground Point Re/Classification: select = xyzirnc
    Ground Point Re/Classification->>Spatial Interpolation: B) Progressive Morphological Filter (PMF)
    Ground Point Re/Classification->>Spatial Interpolation: C) Cloth Simulation Function (CSF)
  else choose Spatial Interpolation Algorithm
    Note right of Spatial Interpolation: lidR:: grid_terrain
    Spatial Interpolation->> DTM:Triangulated Irregular Networks (TIN)
    Spatial Interpolation->> DTM:Inverse Distance Weighing (IDW)
  end
")
################################################################################
###---------------------------#Different workflow versions#-----------------####
################################################################################
#workflow thesis - scheme
mermaid("graph TB
        A[LiDAR las/laz files]-->|1 poss. morphometric extraction|B[DTM/MSTPI]
        A[LiDAR las/laz files]-->|0 data preprocessing|A[LiDAR las/laz files]
        B[DTM/MSTPI]-->|2 iMound|C[filt diff ifDTM/ifdDTM]
        C[filt diff ifDTM/ifdDTM]-->|3 segmentation|D[segments with descriptors]
        D[segments with descriptors]-->|4 thresholding|E[possible mound segments]
        E[possible mound segments]-->|5 verification|F[detected burial mounds]

        style A fill:#FFF, stroke:#333, stroke-width:px
        style B fill:#F5DEB3, stroke:#8B7E66, stroke-width:2px
        style C fill:#DC8A3B, stroke:#564109, stroke-width:2px
        style D fill:#B6AE4B, stroke:#626610, stroke-width:2px
        style E fill:#8DA49C, stroke:#43595E, stroke-width:2px
        style F fill:#AEA594, stroke:#1C1A09, stroke-width:2px, stroke-dasharray: 5 5")


#Workflow of the thesis - simple
mermaid("
sequenceDiagram
  DTM/MTPI->>fDTM/fdDTM: filter
  Note right of DTM/MTPI: raster::focal, fun=mean
  fDTM/fdDTM->>ifDTM/ifdDTM: invert raster
  Note right of fDTM/fdDTM: spatialEco::raster.invert
  ifDTM/ifdDTM->>pf ifDTM/ifdDTM: Wang & Liu 2006 fill pits
  Note right of ifDTM/ifdDTM: RSAGA:: ta_preprocessor 4
  pf ifDTM/ifdDTM->>diff ifDTM/ifdDTM: ifDTM - pf ifDTM
  diff ifDTM/ifdDTM->> filt diff ifDTM/ifdDTM: filter
  Note right of diff ifDTM/ifdDTM: raster::focal, fun=?
  filt diff ifDTM/ifdDTM->> Segmentation WS/RG: segment
  Note right of filt diff ifDTM/ifdDTM: RSAGA:: imagery_segm 0/2+3
  Segmentation WS/RG->>Segments: polygonize
  Note right of Segments: RSAGA:: shapes_grid 6
  Segments->>Joined Segments: join neighbors
  Joined Segments->>Segments SHI: compute Shape Index
  Note right of Joined Segments: RSAGA:: shapes_polygons 7
  Segments SHI->>Segment Descriptors: calculate variables
  Note right of Segments SHI: Niculită 2020
  Segment Descriptors->>possible barrows: thresholds
")

#more complex
mermaid("
sequenceDiagram
  alt choose Data Preparation Method
    DTM->>dDTM: MTPI
    Note left of dDTM: RSAGA:: ta_morphometry 28
    DTM->>dDTM: STEP 1 POSS. MORPHOMETRY
    dDTM->>fDTM/fdDTM: low-pass/focal filter
    Note right of dDTM: raster::focal, fun=mean
    DTM->>fDTM/fdDTM: low-pass/focal filter
    Note right of dDTM: raster::focal, fun=mean
    fDTM/fdDTM->>ifDTM/ifdDTM: invert raster
    Note right of fDTM/fdDTM: spatialEco::raster.invert
    ifDTM/ifdDTM->>pf ifDTM/ifdDTM: Wang & Liu 2006 fill pits
    Note right of ifDTM/ifdDTM: RSAGA:: ta_preprocessor 4
    pf ifDTM/ifdDTM->>diff ifDTM/ifdDTM: ifDTM - pf ifDTM
    dDTM->>diff ifDTM/ifdDTM: STEP 2 iMound
    diff ifDTM/ifdDTM->> filt diff ifDTM/ifdDTM: choose adapt filter
    Note right of diff ifDTM/ifdDTM: raster::focal, fun=?
  else choose Segmentation Algorithm
    filt diff ifDTM/ifdDTM->> Segmentation: Watershed
    Note right of filt diff ifDTM/ifdDTM: RSAGA:: imagery_segm 0
    filt diff ifDTM/ifdDTM->> Segmentation: Region Growing
    Note right of filt diff ifDTM/ifdDTM: RSAGA:: imagery_segm 2+3
    Segmentation->>Segments: polygonize
    Note left of Segments: RSAGA:: shapes_grid 6
    Segments->>Joined Segments: join neighbors
    Note right of Segments: custom R function
    Joined Segments->>Segments & SI: compute Shape Index
    Note right of Joined Segments: RSAGA:: shapes_polygons 7
    Segments & SI->>Segment Descriptors: calculate Descriptors
    diff ifDTM/ifdDTM->>Segment Descriptors: STEP 3 SEGMENTATION
    Note right of Segments & SI: Niculită 2020
    Segment Descriptors->>possible mound segments: STEP 4: thresholding
    Note left of possible mound segments: of Index & Descriptor values
    possible mound segments->>detected burial mounds: STEP 5: VERIFICATION
  end
")
