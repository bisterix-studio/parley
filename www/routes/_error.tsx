// Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

import { HttpError, type PageProps } from "fresh";
import Header from "../components/Header.tsx";

// Adapted from: https://github.com/denoland/fresh

export function ServerCodePage(
  props: ServerCodePageProps,
) {
  return (
    <>
      <Header title="error" active={props.url.pathname} />
      <section class="mt-64">
        <div class="text-center">
          <h1 class="text-6xl md:text-9xl font-extrabold">
            {props.serverCode}
          </h1>

          <p class="p-4 text-2xl md:text-3xl">
            {props.codeDescription}
          </p>

          <p class="p-4">
            <a href="/" class="hover:underline">Back to the Homepage</a>
          </p>
        </div>
      </section>
    </>
  );
}

export default function PageNotFound(props: PageProps) {
  const error = props.error;
  if (error instanceof HttpError) {
    if (error.status === 404) {
      return ServerCodePage({
        url: props.url,
        serverCode: 404,
        codeDescription: "Couldn't find what you're looking for.",
      });
    }
  }

  return ServerCodePage({
    url: props.url,
    serverCode: 500,
    codeDescription: "Oops! Something went wrong.",
  });
}

interface ServerCodePageProps {
  url: URL;
  serverCode: number;
  codeDescription: string;
}
