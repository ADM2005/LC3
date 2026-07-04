package State_pkg;

typedef enum logic[3:0]
{
    UPDATE_PC,
    FETCH,
    DECODE,
    ALU,
    TARGET_PC,
    MEMORY_ADDR,
    IND_MEMORY,
    READ_MEMORY,
    WRITE_MEMORY,
    WRITE_REGISTER,
    ILLEGAL
} PROCESSOR_STATE;

typedef enum logic[1:0]
{
    INSTR_CONTROL = 2'b00,
    INSTR_ALU = 2'b01,
    INSTR_MEMORY = 2'b10,
    INSTR_INVALID = 2'b11
} iType_t;

typedef enum logic[1:0]
{
    MEM_WRITE_REG = 2'b00,
    MEM_READ = 2'b01,
    MEM_IND = 2'b10,
    MEM_WRITE = 2'b11
} maType_t;

typedef enum logic
{
    IND_READ = 1'b1,
    IND_WRITE = 1'b0
} indType_t;

typedef struct packed {
    iType_t iType;
    maType_t maType;
    indType_t indType;
} cCtrl_t;

typedef struct packed {
    logic pEn;                       // Enables the UpdatePC module to change the program counter.
    logic fEn;                       // Enables the Fetch module to start a memory fetch.
    logic dEn;                       // Enables the Decode module to read the instruction from the memory bus .
    logic rWe;                       // Enables the Registers module to store dr into the register identified by drID.
    logic [2:0] mOp;                  // Indicates the type of memory operation (0 0 0) (Enable Read/Write Direct/Indirect).
} output_t;

endpackage : State_pkg