# Brain Blood Flow Analysis

## Project Background and Research Foundation
This project emerges from groundbreaking research in stroke treatment and diagnosis, specifically building upon the work of Dr. Shlomi Peretz and colleagues at Shamir Medical Center. Their 2022 study in the American Journal of Neuroradiology introduced a novel approach to predicting stroke outcomes by analyzing venous flow patterns.

### Original Research Context
Dr. Peretz's study revealed that:
- Deep venous outflow patterns can predict stroke outcomes after M1 thrombectomy
- Delayed venous drainage correlates with striatocapsular infarction
- CTP imaging data contains valuable but previously unutilized venous flow information

### Clinical-Academic Collaboration
This software project represents a unique collaboration between:
- **Clinical Expertise**: Dr. Shlomi Peretz and the Neurology Department at Shamir Medical Center
  - Provided clinical guidance and validation
  - Shared real patient data for development and testing
  - Defined clinical requirements and use cases
- **Academic Development**: HIT Faculty of Electrical and Electronics Engineering
  - Developed automated analysis tools
  - Implemented advanced image processing algorithms
  - Created user-friendly visualization methods

## Project Goals and Innovation
Building on Dr. Peretz's findings, this project aims to:
1. **Automate Analysis**: 
   - Convert manual venous flow measurements to automated processes
   - Provide consistent, reproducible results

2. **Enhance Visualization**:
   - Create color-coded flow maps
   - Visualize both arterial and venous flow patterns
   - Generate intuitive clinical presentations

3. **Support Clinical Decision-Making**:
   - Provide rapid assessment tools for emergency settings
   - Enable better prediction of stroke outcomes
   - Support treatment planning

## Technical Implementation
The project consists of four main processing stages:
1. **DICOM Processing**: Automated sorting and organization of medical imaging data
2. **Structure Creation**: Development of standardized data structures
3. **Image Registration**: Two-stage registration process including active contour and edge detection
4. **Flow Analysis**: Calculation and visualization of Time-to-Peak (TTP) patterns

## Research Reference
This work is based on:
> Peretz S, Pardo K, Naftali J, Findler M, Raphaeli G, Barnea R, Khasminsky V, Auriel E. Delayed CTP-Derived Deep Venous Outflow: A Novel Predictor of Striatocapsular Infarction after M1 Thrombectomy. AJNR Am J Neuroradiol. 2022.

Key findings from this research:
- Thalamostriate ΔTTP strongly correlates with striatocapsular infarction
- Venous outflow analysis provides valuable prognostic information
- CTP data can be used for both arterial and venous flow assessment

## Authors and Contributors
### Project Team
- **Yotam Gunders** - B.Sc. in Electrical Engineering, HIT
- **Dr. Amir Handelman** - Academic Supervisor, HIT

### Clinical Team
- **Dr. Shlomi Peretz** - Project Initiator and Clinical Advisor
  - Senior Neurologist, Shamir Medical Center
  - Lead researcher of the foundational study

## Institutional Support
- **Holon Institute of Technology (HIT)**
  - Faculty of Electrical and Electronics Engineering
  - Provided technical expertise and development resources

- **Shamir Medical Center (Assaf Harofeh)**
  - Department of Neurology
  - Provided clinical expertise and validation
  - Supplied medical imaging data for development
  - Supported clinical testing and validation

## Future Directions
Building on this collaboration, future developments may include:
- Performance optimization to improve overall processing speed
- Integration with hospital PACS systems
- Extended analysis of various stroke patterns
- Machine learning implementation for automated analysis
- Multi-center validation studies

## Acknowledgments
Special thanks to:
- The Neurology Department at Shamir Medical Center 
- The patients whose data contributed to this research
- HIT Faculty for technical support and guidance