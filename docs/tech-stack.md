# Tech Stack - CRS FAD

Dokumentasi ini menjelaskan semua teknologi yang digunakan dalam aplikasi CRS FAD.

## 📋 Overview

CRS FAD dibangun dengan teknologi modern full-stack JavaScript/TypeScript, menggunakan Next.js sebagai framework utama yang menggabungkan frontend dan backend dalam satu aplikasi.

## 🎨 Frontend Stack

### Core Framework

#### Next.js 15.5.9
- **Fungsi**: React framework dengan SSR, SSG, dan API routes
- **Fitur yang Digunakan**:
  - App Router (file-based routing)
  - Server Components dan Client Components
  - API Routes untuk backend
  - Middleware untuk authentication
  - Turbopack untuk faster bundling (dev mode)
- **File Konfigurasi**: [`next.config.ts`](../../next.config.ts)

#### React 19.2.3
- **Fungsi**: UI library untuk building user interface
- **Fitur yang Digunakan**:
  - React Hooks (useState, useEffect, useCallback, dll)
  - Server Components untuk server-side rendering
  - Client Components untuk interactive UI
- **Modern Features**: Menggunakan versi terbaru dengan improved performance

#### TypeScript 5
- **Fungsi**: Type-safe JavaScript untuk better development experience
- **Konfigurasi**: [`tsconfig.json`](../../tsconfig.json)
- **Features**: Strict mode, path aliases (`@/*`), ES2017 target

### UI Framework & Styling

#### Tailwind CSS 3.4.1
- **Fungsi**: Utility-first CSS framework
- **Konfigurasi**: [`tailwind.config.ts`](../../tailwind.config.ts)
- **Features**:
  - Custom theme dengan CSS variables
  - Dark mode support (class-based)
  - Custom colors untuk sidebar, cards, dll
  - Responsive design utilities

#### Radix UI
Koleksi komponen headless UI yang accessible:

- `@radix-ui/react-dialog` - Modal dialogs
- `@radix-ui/react-dropdown-menu` - Dropdown menus
- `@radix-ui/react-label` - Accessible labels
- `@radix-ui/react-popover` - Popover components
- `@radix-ui/react-select` - Select components
- `@radix-ui/react-separator` - Separator lines
- `@radix-ui/react-tooltip` - Tooltips

**Kelebihan**: Fully accessible, unstyled, composable

#### shadcn/ui
- **Fungsi**: Collection of reusable components built dengan Radix UI dan Tailwind CSS
- **Lokasi**: [`components/ui/`](../../components/ui/)
- **Components**: button, input, table, dialog, dropdown-menu, dll

### UI Libraries

#### TanStack Table 8.21.3
- **Fungsi**: Powerful table library untuk React
- **Fitur**: Sorting, filtering, pagination, row selection
- **Usage**: Digunakan di [`components/shared/DetailTable.tsx`](../../components/shared/DetailTable.tsx)

#### Framer Motion 11.15.0
- **Fungsi**: Animation library untuk React
- **Usage**: Animations untuk UI transitions dan interactions

#### Lucide React 0.469.0
- **Fungsi**: Icon library
- **Usage**: Icons untuk seluruh aplikasi

### Form & Validation

#### Zod 3.24.1
- **Fungsi**: TypeScript-first schema validation
- **Usage**: Validation schemas di folder [`schemas/`](../../schemas/)
- **Integration**: Digunakan dengan React Hook Form untuk form validation
- **Example**: Lihat [`schemas/customer.ts`](../../schemas/customer.ts)

### Utilities

#### class-variance-authority 0.7.1
- **Fungsi**: Library untuk managing component variants
- **Usage**: Component styling variants

#### clsx 2.1.1 & tailwind-merge 3.3.1
- **Fungsi**: Utilities untuk conditional class names
- **Usage**: Menggabungkan Tailwind classes dengan logic

#### dayjs 1.11.19
- **Fungsi**: Lightweight date manipulation library
- **Usage**: Date formatting dan manipulation di seluruh aplikasi

#### lodash 4.17.21
- **Fungsi**: Utility library untuk JavaScript
- **Usage**: Helper functions (debounce, groupBy, dll)

#### uuid 11.0.3
- **Fungsi**: Generate unique identifiers
- **Usage**: ID generation untuk data

#### voca 1.4.1
- **Fungsi**: String manipulation library
- **Usage**: Text formatting dan manipulation

#### xlsx 0.18.5
- **Fungsi**: Excel file manipulation
- **Usage**: Import/export data ke Excel format

## 🔧 Backend Stack

### API Framework

#### Next.js API Routes
- **Fungsi**: Built-in API routes di Next.js
- **Location**: [`app/api/`](../../app/api/)
- **Features**:
  - RESTful API endpoints
  - Route handlers (GET, POST, PUT, DELETE)
  - Middleware support

### Authentication

#### NextAuth.js 4.24.11
- **Fungsi**: Complete authentication solution untuk Next.js
- **Configuration**: [`app/api/auth/auth_options.ts`](../../app/api/auth/auth_options.ts)
- **Provider**: Credentials Provider dengan custom authorize logic
- **Features**:
  - JWT-based sessions
  - Middleware integration
  - Role-based access control
  - Session management

#### bcrypt 5.1.1
- **Fungsi**: Password hashing
- **Usage**: Hashing passwords untuk secure storage

### Database & ORM

#### Prisma 6.1.0
- **Fungsi**: Next-generation ORM untuk TypeScript/Node.js
- **Schema**: [`prisma/schema.prisma`](../../prisma/schema.prisma)
- **Features**:
  - Type-safe database client
  - Multi-schema support (public, fad)
  - Migration management
  - Query builder

#### PostgreSQL 15
- **Fungsi**: Relational database
- **Schemas**: 
  - `public` - Authentication tables (User, Session, Account)
  - `fad` - Business logic tables (Products, Customers, Orders, dll)
- **Initialization**: SQL scripts di [`_init/`](../../_init/)

### Data Adapter

#### @auth/prisma-adapter 2.7.4
- **Fungsi**: Prisma adapter untuk NextAuth
- **Usage**: Menghubungkan NextAuth dengan Prisma untuk session management

### HTTP Client

#### Axios 1.7.9
- **Fungsi**: HTTP client untuk API calls
- **Usage**: External API integration (Montaz API untuk authentication)

#### form-data 4.0.1
- **Fungsi**: Library untuk creating multipart/form-data
- **Usage**: File uploads dan form submissions

## 📦 Build Tools & Development

### Package Manager
- **npm** - Node package manager
- **Lock File**: [`package-lock.json`](../../package-lock.json)

### Linting & Code Quality
- **ESLint 9** - JavaScript/TypeScript linter
- **Config**: [`eslint.config.mjs`](../../eslint.config.mjs)
- **Integration**: Next.js ESLint config

### CSS Processing
- **PostCSS 8** - CSS processing tool
- **Config**: [`postcss.config.mjs`](../../postcss.config.mjs)

## 🗄️ Database

### PostgreSQL 15
- **Version**: 15
- **Features Used**:
  - Multi-schema database
  - Foreign keys dan constraints
  - Indexes untuk performance
  - Timestamps untuk audit trails
  - JSON columns untuk flexible data storage

### Database Initialization
Scripts di folder [`_init/`](../../_init/):

1. `01-databases.sql` - Create database
2. `02-schemas.sql` - Create schemas
3. `03-types.sql` - Custom types (enums)
4. `04-tables.sql` - Table definitions
5. `05-functions.sql` - Database functions
6. `06-triggers.sql` - Triggers untuk auto-updates
7. `07-data.sql` - Initial data (seed data)

## 🐳 Containerization

### Docker
- **Docker Compose**: Untuk orchestration
- **Files**:
  - [`docker/docker-compose.yaml`](../../docker/docker-compose.yaml) - Database only
  - [`docker/docker-compose.dev.yaml`](../../docker/docker-compose.dev.yaml) - Development
  - [`docker/docker-compose.prod.yaml`](../../docker/docker-compose.prod.yaml) - Production

### Dockerfiles
- **Development**: [`docker/Dockerfile.dev`](../../docker/Dockerfile.dev)
  - Single stage
  - Hot reload support
  - Volume mounting untuk source code

- **Production**: [`docker/Dockerfile.prod`](../../docker/Dockerfile.prod)
  - Multi-stage build (builder + runner)
  - Optimized image size
  - Non-root user untuk security
  - Health checks

## 📊 Logging

### Winston 3.17.0
- **Fungsi**: Logging library
- **Usage**: [`lib/logger.ts`](../../lib/logger.ts)
- **Features**: Structured logging dengan different log levels

## 🔐 Security

- **NextAuth.js** - Secure authentication
- **bcrypt** - Password hashing
- **JWT** - Secure session tokens
- **Middleware** - Route protection
- **Role-based Access Control** - Permission system

## 📱 API Integration

### External APIs
- **Montaz API** - Employee authentication service
  - Endpoint: `https://crs.montaz.id/api/login`
  - Used for: Primary authentication sebelum local auth

## 🎯 Technology Choices Rationale

### Mengapa Next.js?
- Full-stack framework dalam satu aplikasi
- Server-side rendering untuk better SEO dan performance
- Built-in API routes
- Excellent developer experience

### Mengapa Prisma?
- Type-safe database access
- Auto-generated TypeScript types
- Great developer experience
- Support untuk complex queries

### Mengapa PostgreSQL?
- Reliable dan mature
- Support untuk complex relationships
- Multi-schema untuk better organization
- Excellent performance

### Mengapa Docker?
- Consistent development environment
- Easy deployment
- Isolation dari host system
- Scalability

## 📚 Versi Teknologi

Semua versi dapat dilihat di [`package.json`](../../package.json). Versi utama:

- Node.js: 20 (dari Dockerfile)
- Next.js: 15.5.9
- React: 19.2.3
- TypeScript: 5
- PostgreSQL: 15
- Prisma: 6.1.0

## 🔄 Update Strategy

Untuk update dependencies:

```bash
# Check outdated packages
npm outdated

# Update specific package
npm update <package-name>

# Update all (minor/patch)
npm update

# Major updates (careful!)
npm install <package>@latest
```

---

**Selanjutnya**: Baca [Frontend Architecture](./frontend-architecture.md) untuk memahami struktur frontend aplikasi.