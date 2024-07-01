### 디렉토리 구조

common-infra<br>
├── modules<br>
│   └── vpc<br>
│       ├── outputs.tf<br>
│       ├── variables.tf<br>
│       └── vpc.tf<br>
├── prod<br>
│   └── vpc<br>
│       ├── outputs.tf<br>
│       ├── terraform_backend.tf<br>
│       ├── variables.tf<br>
│       └── vpc.tf<br>
└── readme.md<br>

modules 폴더는 vpc를 생성하기 위한 공통module폴더이고,<br>
prod 는 운영에서 실제 모듈호출해서 사용하기 위한 경로이다.