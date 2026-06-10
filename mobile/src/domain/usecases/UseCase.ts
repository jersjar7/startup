// A use case is a single application operation. `void` input is allowed.
export interface UseCase<Input, Output> {
  execute(input: Input): Promise<Output>;
}
